# frozen_string_literal: true

# Additive restoration: source IDs are mapped to destination catalog identities.
class HistoricalCatalogImport
  ACCOUNT_IDENTITY_FIELDS = %w[email provider uid].freeze
  def call(snapshot)
    @snapshot = snapshot
    @resorts = {}
    @passes = {}
    @accounts = {}
    ApplicationRecord.transaction do
      restore_resorts
      restore_passes
      restore_relationships
    end
    { resorts: Resort.count, passes: SeasonPass.count, pass_resorts: SeasonPassResort.count,
      account_passes: AccountSeasonPass.count, ski_days: AccountSkiDay.count }
  end

  private

  def restore_resorts
    @snapshot.fetch('resorts').each do |row|
      record = Resort.where('LOWER(name) = ?', row.fetch('name').downcase).first
      record ||= Resort.create!(row.slice('name', 'city', 'state', 'lat', 'long'))
      @resorts[row.fetch('id')] = record
    end
  end

  def restore_passes
    @snapshot.fetch('season_passes').each do |row|
      record = SeasonPass.where('LOWER(name) = ?', row.fetch('name').downcase).first
      @passes[row.fetch('id')] = record || SeasonPass.create!(name: row.fetch('name'))
    end
    @snapshot.fetch('accounts').each do |row|
      account = Account.find_by(id: row.fetch('id'))
      next unless account && ACCOUNT_IDENTITY_FIELDS.all? { |field| account.public_send(field) == row[field] }

      @accounts[row.fetch('id')] = account
    end
  end

  def restore_relationships
    @snapshot.fetch('season_pass_resorts').each do |row|
      SeasonPassResort.find_or_create_by!(resort: @resorts.fetch(row.fetch('resort_id')),
        season_pass: @passes.fetch(row.fetch('season_pass_id')))
    end
    @snapshot.fetch('account_season_passes').each do |row|
      next unless @accounts[row.fetch('account_id')]

      AccountSeasonPass.find_or_create_by!(account: @accounts.fetch(row.fetch('account_id')),
        season_pass: @passes.fetch(row.fetch('season_pass_id')))
    end
    restore_ski_days
  end

  def restore_ski_days
    @snapshot.fetch('account_ski_days').each do |row|
      next unless @accounts[row.fetch('account_id')]

      record = AccountSkiDay.find_or_initialize_by(account: @accounts.fetch(row.fetch('account_id')),
        resort: @resorts.fetch(row.fetch('resort_id')), start_date: row.fetch('start_date'))

      if record.persisted? && record.status != row['status']
        raise ArgumentError,
          'Ski-day status conflict requires review'
      end

      record.update!(status: row['status']) if record.new_record?
    end
  end
end
