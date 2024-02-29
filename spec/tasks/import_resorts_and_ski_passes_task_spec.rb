# frozen_string_literal: true

require 'rails_helper'
require 'rake'

RSpec.describe 'import:resorts_and_season_passes' do
  before do
    Rails.application.load_tasks

    @csv_file_path = Rails.root.join('spec', 'fixtures', 'test_resorts.csv')
    binding.pry
    CSV.open(@csv_file_path, 'w') do |csv|
      csv << %w[name city state season_passes]
      csv << ['Breck', 'Denver', 'CO', 'season Pass A, season Pass B']
    end

    allow(CSV).to receive(:foreach).with(@csv_file_path, headers: true).and_yield({ 'name' => 'Resort A', 'city' => 'Denver', 'state' => 'CO', 'season_passes' => 'season Pass A, season Pass B' })
  end

  it 'imports resorts and season passes from CSV file' do
    allow(CSV).to receive(:foreach).and_yield({ 'name' => 'Resort A', 'location' => 'Location A', 'rating' => '4', 'season_passes' => 'season Pass A, season Pass B' })
    expect { Rake::Task['import:resorts_and_season_passes'].invoke }.to change { Resort.count }.by(1)
                                                                                               .and change { SeasonPass.count }.by(2)
                                                                                                                               .and change { SeasonPassResort.count }.by(2)
  end
end
