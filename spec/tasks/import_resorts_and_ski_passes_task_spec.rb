require 'rails_helper'
require 'rake'

RSpec.describe 'import:resorts_and_ski_passes' do
  before do
    Rails.application.load_tasks
    lat = Faker::Address.latitude.to_s
    long = Faker::Address.longitude.to_s

    @csv_file_path = Rails.root.join('spec', 'fixtures', 'test_resorts.csv')
    CSV.open(@csv_file_path, 'w') do |csv|
      csv << %w[name city state ski_passes latitude longitude]
      csv << ['Breck', 'Denver', 'CO', 'Ski Pass A, Ski Pass B', lat, long]
    end

    allow(CSV).to receive(:foreach).with(@csv_file_path,
                                         headers: true).and_yield({ 'name' => 'Resort A', 'city' => 'Denver', 'state' => 'CO', 'ski_passes' => 'Ski Pass A, Ski Pass B', 'latitude' => lat,
                                                                    'longitude' => long })
  end

  it 'imports resorts and ski passes from CSV file' do
    allow(CSV).to receive(:foreach).and_yield({ 'name' => 'Breck', 'city' => 'Denver', 'state' => 'CO', 'ski_passes' => 'Ski Pass A, Ski Pass B', 'latitude' => lat, 'longitude' => long })

    expect { Rake::Task['import:resorts_and_ski_passes'].invoke }.to change { Resort.count }.by(1)
                                                                                            .and change { SeasonPass.count }.by(2)
                                                                                                                            .and change { SeasonPassResort.count }.by(2)
  end
end
