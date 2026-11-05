# frozen_string_literal: true

class BedRequest < ApplicationRecord
  belongs_to :bed
  belongs_to :user
  belongs_to :guest_stay, optional: true
  validate :guest_matches_request
  validate :member_priority, if: :confirmed?
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

  def guest_matches_request
    return unless guest_stay && bed

    valid = guest_stay.house_season.lodging_id == bed.room.lodging_id && guest_stay.host_id == user_id &&
      arrival && departure && arrival >= guest_stay.arrival && departure <= guest_stay.departure
    errors.add(:guest_stay, 'must match this host, house and dates') unless valid
    errors.add(:guest_stay, 'must be approved before confirming a bed') if confirmed? && !guest_stay.approved?
  end

  def member_priority
    return unless guest_stay && bed && arrival && departure
    return unless bed.bed_requests.requested.where(guest_stay_id: nil).overlapping(arrival, departure).exists?

    errors.add(:base, 'Review roommate requests before confirming a guest bed')
  end

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
