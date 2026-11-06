# frozen_string_literal: true

namespace :history do
  desc 'Dry-run Bear Lodge import; set APPLY=true only after reviewing the private snapshot'
  task bear_lodge: :environment do
    abort 'Historical import is development-only' unless Rails.env.development?
    abort 'Unset DATABASE_URL before importing' if ENV['DATABASE_URL'].present?

    unless ApplicationRecord.connection_db_config.database == 'powpals_beta_revival_development'
      abort 'Use the isolated powpals_beta_revival_development database'
    end

    snapshot = JSON.parse(File.read(ENV.fetch('SNAPSHOT')))
    apply = ENV['APPLY'] == 'true'
    counts = HistoricalHouseImport.new(snapshot).call(apply: apply)
    puts JSON.pretty_generate(applied: apply, counts: counts)
  end
end
