# frozen_string_literal: true

class HouseFinancialReferenceImport
  def initialize(season, source_key:)
    @season = season
    @source_key = source_key
  end

  def call(rows)
    raise ArgumentError, 'Financial sheet imports must target a historical reference season' unless @season.reference?

    @season.with_lock do
      rows.each_with_index { |row, index| import_row(row, index) }
    end
    { rows: rows.size, entries: @season.house_ledger_entries.count }
  end

  private

  def import_row(row, index)
    attributes = { kind: row.fetch('kind'), description: row.fetch('description'),
                   month_on: Date.iso8601(row.fetch('month_on')), amount_cents: row.fetch('amount_cents'),
                   source_data: row }
    entry = @season.house_ledger_entries.find_or_initialize_by(source_key: "#{@source_key}:#{index + 1}")
    if entry.persisted?
      raise ArgumentError, 'Financial source row changed; review before replacing it' if
        attributes.any? { |field, value| entry.public_send(field) != value }

      return
    end

    entry.assign_attributes(attributes)
    entry.save!
    return unless row.fetch('received') == true

    entry.record_payment!(amount_cents: entry.amount_cents, source_reported: true,
      reference: 'Source sheet marked Y; exact payment date and transaction ID not supplied')
  end
end
