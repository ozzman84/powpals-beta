# frozen_string_literal: true

class GuestFeeQuote
  def initialize(season)
    @season = season
  end

  def call(arrival:, departure:, guests:, dogs: 0)
    raise ArgumentError, 'Guest rates have not been confirmed for this season' unless @season.confirmed?

    arrival = Date.iso8601(arrival.to_s)
    departure = Date.iso8601(departure.to_s)
    guests = Integer(guests.to_s, 10)
    dogs = Integer(dogs.to_s, 10)
    validate_dates!(arrival, departure, guests, dogs)
    nights = (arrival...departure).to_a.drop(@season.free_nights)
    fee = nights.sum { |date| @season.guest_rates.fetch(Date::DAYNAMES[date.wday]) } * guests
    fee + dog_fee((departure - arrival).to_i, dogs)
  end

  private

  def validate_dates!(arrival, departure, guests, dogs)
    valid = guests.positive? && dogs >= 0 && departure > arrival && departure - arrival <= 183 &&
      arrival >= @season.starts_on && departure - 1 <= @season.ends_on
    raise ArgumentError, 'Use valid guest counts and occupied nights within the rental season' unless valid
  end

  def dog_fee(nights, dogs)
    return 0 if dogs.zero?

    raise ArgumentError, 'Confirm the dog fee and whether it applies per night or per stay' if
      @season.unconfirmed? || @season.dog_fee_cents.nil?

    @season.dog_fee_cents * dogs * (@season.per_night? ? nights : 1)
  end
end
