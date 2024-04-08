# frozen_string_literal: true

namespace :import do
  desc 'Process CSV for Calendar entries'
  task users_calendars_for_lodging: :environment do
    require 'csv'

    file_path = 'app/assets/csv/SkiHausExport - Sheet1.csv'
    CSV.foreach(file_path, headers: true) do |row|
      starting_count = Calendar.all.size
      first, last = row['name'].split(' ')
      user = User.find_by(first_name: first, last_name: last)
      lodging = Lodging.find_by(title: row['lodging_name'])
      next unless user && lodging

      row.headers.each do |header|
        next unless header.match?(%r{\d{1,2}/\d{1,2}/\d{4}}) # Match YYYY-MM-DD format

        date = Date.strptime(header, '%m/%d/%Y')
        value = row[header].to_i

        status, guest_count = case value
                              when 0
                                ['away', 0]
                              when value.positive?
                                ['staying', value - 1]
                              else
                                next
                              end

        Calendar.create_with(status:, guest_count:)
                .find_or_create_by(date:, user:, lodging:)
      end

      ending_count = Calendar.all.size
      p "#{user.full_name} #{ending_count - starting_count} entries"
    end

    puts 'CSV processing completed.'
  end
end
