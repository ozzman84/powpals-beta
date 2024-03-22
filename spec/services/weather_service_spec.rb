# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeatherService do
  #   describe '.fetch_forecast_for_resort' do
  #     let(:resort_name) { 'Breckenridge' }
  #     let(:api_response) { File.read(Rails.root.join('spec/fixtures/weather_api_response.json')) }

  #     before do
  #       stub_request(:get, /weatherapi.com/)
  #         .to_return(status: 200, body: api_response)
  #     end

  #     it 'fetches weather forecast data for a given resort' do
  #       forecast = WeatherService.fetch_forecast_for_resort(resort_name)
  #       expect(forecast).not_to be_nil
  #       expect(forecast['forecast']['forecastday'].size).to eq(10)
  #     end
  #   end
end
