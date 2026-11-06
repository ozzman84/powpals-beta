# frozen_string_literal: true

namespace :history do
  desc 'Import a reviewed TSV stay sheet into the isolated local revival database'
  task stay_sheet: :environment do
    abort 'Use local development without DATABASE_URL' unless Rails.env.development? && ENV['DATABASE_URL'].blank?

    abort 'Use the isolated revival database' unless
      ApplicationRecord.connection_db_config.database == 'powpals_beta_revival_development'

    lodging = Lodging.find(ENV.fetch('LODGING_ID'))
    importer = HouseStaySheetImport.new(lodging, source_key: ENV.fetch('SOURCE_KEY'))
    puts JSON.pretty_generate(importer.call(File.read(ENV.fetch('SHEET_PATH'))))
  end
end
