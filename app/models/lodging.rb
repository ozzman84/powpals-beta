# frozen_string_literal: true

class Lodging < ApplicationRecord
  has_many :house_invitations, dependent: :destroy
  has_many :house_seasons, dependent: :restrict_with_error
  has_many :roommates, dependent: :destroy
  has_many :users, through: :roommates
  has_many :rooms, dependent: :destroy
  has_many :calendars, dependent: :destroy

  validates :title, presence: true
  validates :max_guests, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :max_cars, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validate :valid_season

  def valid_season
    errors.add(:season_end, 'must follow the start date') if season_start && season_end && season_end < season_start
    errors.add(:season_start, 'and end date must both be supplied') if season_start.present? != season_end.present?
  end

  def bed_spaces
    spaces = Bed.where(room_id: rooms.select(:id)).pluck(:size, :capacity).sum do |size, capacity|
      capacity || Bed::CAPACITY.fetch(size.to_sym, 0)
    end
    spaces if spaces.positive?
  end

  def advisory_capacity
    max_guests || bed_spaces
  end

  def capacity_source
    max_guests ? 'configured guidance' : 'bed spaces from inventory'
  end

  def capacity_warnings(occupants:, cars:)
    warnings = []
    if advisory_capacity && occupants > advisory_capacity
      warnings << "Sleeping guidance exceeded: #{occupants} people for #{advisory_capacity} #{capacity_source}."
    end

    warnings << "Parking guidance exceeded: #{cars} cars for #{max_cars} spaces." if max_cars && cars > max_cars
    warnings
  end

  enum :status, {
    draft: 'draft',
    published: 'published',
    archived: 'archived'
  }, default: 'draft', validate: true

  def full_address
    [[street, address2].compact_blank.join(' '), [city, state].compact_blank.join(', '),
      zip_code].compact_blank.join(' ')
  end
end
