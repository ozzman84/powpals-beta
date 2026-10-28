# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'import:resorts_and_season_passes' do
  it 'can import the same resort and passes twice without duplicate associations' do
    Rails.application.load_tasks unless Rake::Task.task_defined?('import:resorts_and_season_passes')
    row = { 'name' => 'Winter Park', 'city' => 'Winter Park', 'state' => 'CO',
            'latitude' => '39.8', 'longitude' => '-105.8', 'season_passes' => 'Epic, Local' }
    allow(CSV).to receive(:foreach).and_yield(row)
    task = Rake::Task['import:resorts_and_season_passes']
    2.times do
      task.reenable
      task.invoke
    end
    expect(Resort.where(name: 'Winter Park').count).to eq(1)
    expect(SeasonPassResort.count).to eq(2)
  end
end
