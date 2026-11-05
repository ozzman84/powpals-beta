# frozen_string_literal: true

class StayRange
  Result = Struct.new(:arrival, :created, :unchanged, :warnings, keyword_init: true)

  def initialize(lodging, user)
    @lodging = lodging
    @user = user
  end

  def call(arrival:, checkout: nil, **attributes)
    arrival = Date.iso8601(arrival.to_s)
    checkout = checkout.present? ? Date.iso8601(checkout.to_s) : arrival + 1
    raise ArgumentError, 'Checkout must follow arrival, with at most 183 nights' unless
      checkout > arrival && checkout - arrival <= 183

    @lodging.with_lock { save_nights(arrival, checkout, attributes) }
  end

  private

  def save_nights(arrival, checkout, attributes)
    if (@lodging.season_start && arrival < @lodging.season_start) ||
        (@lodging.season_end && checkout - 1 > @lodging.season_end)
      raise ArgumentError, 'All occupied nights must fall within the rental season'
    end

    dates = (arrival...checkout).to_a
    existing = @user.calendars.where(lodging: @lodging, date: dates).pluck(:date)
    records = (dates - existing).map do |date|
      @user.calendars.create!(attributes.merge(lodging: @lodging, date: date))
    end
    Result.new(arrival: arrival, created: records.size, unchanged: existing.size,
      warnings: records.flat_map(&:capacity_warnings).uniq)
  end
end
