# frozen_string_literal: true

class BedAvailability
  attr_reader :bed, :occupants, :pending_count

  def initialize(bed, requests)
    @bed = bed
    @occupants = requests.select(&:confirmed?)
    @pending_count = requests.count(&:requested?)
  end

  def capacity
    bed.capacity || Bed::CAPACITY.fetch(bed.size.to_sym, 0)
  end

  def taken
    occupants.sum(&:spaces)
  end

  def available
    [capacity - taken, 0].max
  end

  def status
    return 'Taken' if available.zero?
    return 'Partly taken' if taken.positive?

    'Available'
  end
end
