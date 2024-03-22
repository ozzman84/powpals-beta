# frozen_string_literal: true

require 'httparty'

class WeatherService
  include HTTParty
  BASE_URL = 'http://api.weatherapi.com/v1'

  def self.fetch_forecast_for_resort(resort_name)
    query = CGI.escape(resort_name)
    url = "#{BASE_URL}/forecast.json?key=#{ENV['WEATHER_API_KEY']}&q=#{query}&days=10"
    response = HTTParty.get(url)
    JSON.parse(response.body) if response.success?
  end
end
