# frozen_string_literal: true

require 'httparty'

class WeatherService
  BASE_URL = 'https://api.weatherapi.com/v1'

  def self.fetch_forecast_for_resort(resort_name)
    return if ENV['WEATHER_API_KEY'].blank?

    response = HTTParty.get("#{BASE_URL}/forecast.json", timeout: 5,
      query: { key: ENV.fetch('WEATHER_API_KEY', nil), q: resort_name, days: 10 })
    JSON.parse(response.body) if response.success?
  rescue JSON::ParserError, Timeout::Error, SocketError, IOError, SystemCallError, OpenSSL::SSL::SSLError
    nil
  end
end
