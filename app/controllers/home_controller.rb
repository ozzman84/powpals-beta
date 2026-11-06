# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    return unless account_signed_in?

    @resorts = current_account.resort_data_for_multiple_days
    @weather_forecasts = @resorts.to_h do |name, _data|
      forecast = Rails.cache.read("weather_#{name}")
      queue_weather_refresh(name) unless forecast
      days = forecast.is_a?(Hash) ? forecast.dig('forecast', 'forecastday') : nil
      [name, Array(days).select { |day| day.is_a?(Hash) }.index_by { |day| day['date'] }]
    end
  end

  private

  def queue_weather_refresh(name)
    return if ENV['WEATHER_API_KEY'].blank?
    return unless Rails.cache.write("weather_refresh_#{name}", true, expires_in: 1.minute, unless_exist: true)

    RefreshResortWeatherJob.perform_later(name)
  end
end
