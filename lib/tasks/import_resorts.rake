# frozen_string_literal: true

namespace :import do
  desc 'Import resorts and associate with season passes from CSV'
  task resorts_and_season_passes: :environment do
    require 'csv'

    file_path = 'app/assets/csv/Epic Resort List 23_24 - Sheet1 (2).csv' # Update the path to your CSV file
    CSV.foreach(file_path, headers: true) do |row|
      resort = Resort.find_or_create_by(name: row['name'], city: row['city'], state: row['state']) do |r|
        r.name = row['name']
        r.city = row['city']
        r.state = row['state']
      end

      resort.update(lat: row['latitude'].to_f, long: row['longitude'].to_f)

      if row['season_passes']
        season_pass_names = row['season_passes'].split(',') # Assuming season_passes are provided as comma-separated values in the CSV
        season_passes = season_pass_names.map { |name| SeasonPass.find_or_create_by(name:) }
        resort.season_passes << season_passes
      end
    end
  end
end
