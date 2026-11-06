# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Weather refresh' do
  include Devise::Test::IntegrationHelpers
  include ActiveJob::TestHelper

  let(:user) { create(:user) }
  let!(:resort) { create(:resort) }

  around do |example|
    previous_cache = Rails.cache
    previous_key = ENV.fetch('WEATHER_API_KEY', nil)
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    ENV['WEATHER_API_KEY'] = 'test-key'
    example.run
  ensure
    Rails.cache = previous_cache
    ENV['WEATHER_API_KEY'] = previous_key
    clear_enqueued_jobs
  end

  before do
    sign_in user.account
  end

  it 'queues forecasts without making a weather request during page rendering' do
    expect(WeatherService).not_to receive(:fetch_forecast_for_resort)
    expect { get root_path }.to have_enqueued_job(RefreshResortWeatherJob).with(resort.name)
    expect(response).to have_http_status(:ok)
  end

  it 'does not queue duplicate refreshes when the page is reloaded' do
    get root_path
    expect { get root_path }.not_to have_enqueued_job(RefreshResortWeatherJob)
  end

  it 'shows forecasts after the background job populates the cache' do
    payload = { 'forecast' => { 'forecastday' => [{ 'date' => Date.current.iso8601,
                                                    'day' => { 'totalsnow_cm' => 2.54 } }] } }
    allow(WeatherService).to receive(:fetch_forecast_for_resort).and_return(payload)
    RefreshResortWeatherJob.perform_now(resort.name)
    get root_path
    expect(response.body).to include('1.0 in')
  end
end
