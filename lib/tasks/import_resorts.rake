# frozen_string_literal: true

namespace :import do
  desc 'Import resorts and associate with season passes from CSV'
  task resorts_and_season_passes: :environment do
    require 'csv'
    path = Rails.root.join('app/assets/csv/Epic Resort List 23_24 - Sheet1 (2).csv')
    Resort.transaction do
      CSV.foreach(path, headers: true) do |row|
        resort = Resort.find_or_initialize_by(name: row['name'])
        resort.update!(city: row['city'], state: row['state'], lat: row['latitude'], long: row['longitude'])
        (row['season_passes'] || row['ski_passes']).to_s.split(',').map(&:strip).compact_blank.each do |name|
          pass = SeasonPass.find_or_create_by!(name: name)
          SeasonPassResort.find_or_create_by!(resort: resort, season_pass: pass)
        end
      end
    end
  end
end
