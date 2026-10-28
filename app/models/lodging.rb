# frozen_string_literal: true

class Lodging < ApplicationRecord
  has_many :roommates, dependent: :destroy
  has_many :users, through: :roommates
  has_many :rooms, dependent: :destroy
  has_many :calendars, dependent: :destroy

  validates :title, presence: true
  validates :max_guests, numericality: { only_integer: true, greater_than: 0 }
  validates :max_cars, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validate :valid_season

  def valid_season
    errors.add(:season_end, 'must follow the start date') if season_start && season_end && season_end < season_start
    errors.add(:season_start, 'and end date must both be supplied') if season_start.present? != season_end.present?
  end

  #   validates :max_capacity, numericality: { greater_than: 0, less_than: 101 }, if: { status: :published}

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
