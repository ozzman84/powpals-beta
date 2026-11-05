# frozen_string_literal: true

class BedRequest < ApplicationRecord
  belongs_to :bed
  belongs_to :user
  has_one :room, through: :bed
  enum :status, { requested: 'requested', confirmed: 'confirmed', declined: 'declined', cancelled: 'cancelled' },
    validate: true
  validates :arrival, :departure, presence: true
  validates :spaces, numericality: { only_integer: true, greater_than: 0 }
  validate :valid_stay
  validate :available_spaces, if: :confirmed?
  attr_readonly :bed_id, :user_id, :arrival, :departure, :spaces
  scope :overlapping, ->(arrival, departure) { where('arrival < ? AND departure > ?', departure, arrival) }

  def transition!(value)
    bed.with_lock { update!(status: value) }
  end

  private

  def valid_stay
    return unless bed && arrival && departure

    house = bed.room.lodging
    valid = departure > arrival && departure - arrival <= 183 &&
      (!house.season_start || arrival >= house.season_start) && (!house.season_end || departure - 1 <= house.season_end)
    errors.add(:base, 'Use occupied nights within the rental season') unless valid
    return if house.roommates.exists?(user_id: user_id, access_state: 'active', role: Roommate.roles.keys - ['guest'])

    errors.add(:user, 'must be an accepted roommate in this house')
  end

  def available_spaces
    return unless bed && arrival && departure && spaces && departure > arrival && departure - arrival <= 183

    others = bed.bed_requests.confirmed.where.not(id: id).overlapping(arrival, departure)
    capacity = bed.capacity || Bed::CAPACITY.fetch(bed.size.to_sym, 0)
    return unless (arrival...departure).any? do |night|
      others.select do |request|
        request.arrival <= night && request.departure > night
      end.sum(&:spaces) + spaces > capacity
    end

    errors.add(:base, 'Confirmed sleeping assignments would overlap; review existing assignments first')
  end
end
