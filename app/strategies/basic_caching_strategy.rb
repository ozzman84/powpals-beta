class BasicCachingStrategy
  def initialize(service)
    @service = CachingWeatherServiceDecorator.new(service)
  end

  def fetch_forecast_for_resort(resort_name)
    @service.fetch_forecast_for_resort(resort_name)
  end
end
