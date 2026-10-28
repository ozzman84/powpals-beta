# frozen_string_literal: true

class RefreshResortWeatherJob < ApplicationJob
  def perform(resort_name)
    BasicCachingStrategy.new(WeatherService).fetch_forecast_for_resort(resort_name)
  end
end
