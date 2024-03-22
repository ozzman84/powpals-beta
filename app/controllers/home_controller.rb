# frozen_string_literal: true

class HomeController < ApplicationController
  # rubocop:disable all
  def index
    return unless account_signed_in?

    @user = current_account.user
    @resorts = current_account.resort_data_for_multiple_days
    @weather_forecasts = @resorts.each_with_object({}) do |resort, acc|
      forecast_data = BasicCachingStrategy.new(WeatherService).fetch_forecast_for_resort(resort.first)
      acc[resort.first] = forecast_data['forecast']['forecastday'].map do |day|
        {
          date: day['date'],
          snow: day['day']['totalsnow_cm'] / 2.54,
          icon: day['day']['condition']['icon']
        }
      end
    end
  end
  # rubocop:enable all
end
