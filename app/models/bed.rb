# frozen_string_literal: true

class Bed < ApplicationRecord
  belongs_to :room
  has_many :bed_requests, dependent: :restrict_with_error
  before_validation :set_capacity

  enum :size, {
    twin: 'twin',
    full: 'full',
    queen: 'queen',
    king: 'king',
    california_king: 'california_king'
  }, validate: true

  enum :style, {
    mattress: 'mattress',
    airmattress: 'airmattress',
    pullout: 'pullout',
    couch: 'couch',
    bunk: 'bunk',
    sleeping_bag: 'sleeping bag',
    chair: 'chair'
  }, default: 'mattress', validate: true

  validates :label, length: { maximum: 100 }, allow_blank: true

  validate :confirmed_assignments_fit

  validates :capacity, numericality: { only_integer: true, greater_than: 0 }

  CAPACITY = {
    twin: 1,
    full: 2,
    queen: 2,
    king: 2,
    california_king: 2
  }.freeze

  def inventory_name
    label.presence || [size&.humanize, style&.humanize].compact.join(' ')
  end

  private

  def confirmed_assignments_fit
    return unless persisted? && capacity && will_save_change_to_capacity?

    events = bed_requests.confirmed.where('departure > ?', Date.current).flat_map do |request|
      [[[request.arrival, Date.current].max, request.spaces], [request.departure, -request.spaces]]
    end
    occupancy = 0
    exceeds = events.sort.any? do |_date, delta|
      occupancy += delta
      occupancy > capacity
    end
    errors.add(:capacity, 'cannot be lower than existing confirmed assignments') if exceeds
  end

  def set_capacity
    self.capacity ||= CAPACITY[size&.to_sym]
  end
end
