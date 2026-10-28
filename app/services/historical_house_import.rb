# frozen_string_literal: true

# Copies reviewed house history without invoking account emails or current-season callbacks.
class HistoricalHouseImport
  MODELS = [Account, User, Lodging, Roommate, Room, Bed, Calendar].freeze
  TABLES = MODELS.map(&:table_name).freeze
  TRANSIENT_ACCOUNT_FIELDS = %w[reset_password_token reset_password_sent_at remember_created_at
    confirmation_token unlock_token].freeze

  def initialize(snapshot)
    @snapshot = snapshot
  end

  def call(apply: false)
    validate_snapshot!
    ApplicationRecord.transaction(requires_new: true) do
      connection = ApplicationRecord.connection
      connection.execute('LOCK TABLE accounts, users, lodgings, roommates, rooms, beds, calendars IN EXCLUSIVE MODE')
      raise ArgumentError, 'Import requires an empty destination' if MODELS.any?(&:exists?)

      MODELS.each { |model| import_records(model) }
      counts = MODELS.to_h { |model| [model.table_name, model.count] }
      raise ActiveRecord::Rollback unless apply

      MODELS.each { |model| connection.reset_pk_sequence!(model.table_name) }
      counts
    end
    @snapshot.fetch('tables').transform_values(&:size)
  end

  private

  def validate_snapshot!
    raise ArgumentError, 'Unsupported snapshot version' unless @snapshot['version'] == 1

    tables = @snapshot.fetch('tables')
    raise ArgumentError, 'Unexpected snapshot tables' unless tables.keys.sort == TABLES.sort

    houses = tables.fetch('lodgings')
    return if houses.size == 1 && houses.first.fetch('title') == 'Bear Lodge'

    raise ArgumentError, 'Snapshot must contain only the confirmed Bear Lodge house'
  end

  def import_records(model)
    records = @snapshot.fetch('tables').fetch(model.table_name).map do |record|
      attributes = record.slice(*model.column_names)
      normalize_record(model, attributes)
    end
    # Preserve historical values without sending Devise mail or applying current-season capacity callbacks.
    model.insert_all!(records) if records.any? # rubocop:disable Rails/SkipsModelValidations
  end

  def normalize_record(model, attributes)
    # PostgreSQL historical timestamps are UTC strings without an offset.
    model.columns.select { |column| column.type == :datetime }.each do |column|
      value = attributes[column.name]
      attributes[column.name] = Time.find_zone!('UTC').parse(value) if value.is_a?(String)
    end
    case model.name
    when 'Account'
      TRANSIENT_ACCOUNT_FIELDS.each { |field| attributes[field] = nil }
    when 'Roommate'
      attributes['role'] = 'roommate' if attributes['role'].blank?
    when 'Calendar'
      %w[guest_count cars].each { |field| attributes[field] ||= 0 }
    end
    attributes
  end
end
