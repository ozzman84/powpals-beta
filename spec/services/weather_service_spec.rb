# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeatherService do
  around do |example|
    previous = ENV.fetch('WEATHER_API_KEY', nil)
    ENV['WEATHER_API_KEY'] = 'test-key'
    example.run
  ensure
    ENV['WEATHER_API_KEY'] = previous
  end

  it 'returns forecast data from a successful HTTPS response' do
    stub_request(:get, /api.weatherapi.com/).to_return(status: 200, body: '{"forecast":{"forecastday":[]}}')
    expect(described_class.fetch_forecast_for_resort('Winter Park')).to eq('forecast' => { 'forecastday' => [] })
  end

  it 'handles timeouts without breaking the caller' do
    stub_request(:get, /api.weatherapi.com/).to_timeout
    expect(described_class.fetch_forecast_for_resort('Winter Park')).to be_nil
  end

  it 'handles malformed responses' do
    stub_request(:get, /api.weatherapi.com/).to_return(status: 200, body: 'not JSON')
    expect(described_class.fetch_forecast_for_resort('Winter Park')).to be_nil
  end

  it 'handles rejected API requests' do
    stub_request(:get, /api.weatherapi.com/).to_return(status: 403)
    expect(described_class.fetch_forecast_for_resort('Winter Park')).to be_nil
  end
end
