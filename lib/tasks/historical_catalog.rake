# frozen_string_literal: true

namespace :history do
  desc 'Restore missing catalog and matching account relationships from a private reviewed snapshot'
  task catalog: :environment do
    abort 'Use local development without DATABASE_URL' unless Rails.env.development? && ENV['DATABASE_URL'].blank?

    abort 'Use the isolated revival database' unless
      ApplicationRecord.connection_db_config.database == 'powpals_beta_revival_development'

    snapshot = JSON.parse(File.read(ENV.fetch('CATALOG_SNAPSHOT')))
    puts JSON.pretty_generate(HistoricalCatalogImport.new.call(snapshot))
  end
end
