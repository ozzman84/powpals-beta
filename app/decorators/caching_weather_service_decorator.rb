# frozen_string_literal: true

class CachingWeatherServiceDecorator
  def initialize(weather_service)
    @weather_service = weather_service
  end

  def fetch_forecast_for_resort(resort_name)
    Rails.cache.fetch("weather_#{resort_name}", expires_in: 1.hour, skip_nil: true) do
      @weather_service.fetch_forecast_for_resort(resort_name)
    end
  end
end
