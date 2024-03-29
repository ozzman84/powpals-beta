# frozen_string_literal: true

class HomeController < ApplicationController
  protect_from_forgery except: :sign_in
  # rubocop:disable all
  def index
    return unless account_signed_in?

    @user = current_account.user
    @resorts = current_account.resort_data_for_multiple_days
    started = Time.now
    
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
    finished = Time.now
    puts "###### Request took #{(finished - started) * 1000} ms."
  end
  # rubocop:enable all
end
