# frozen_string_literal: true

class HouseSheetCell < ApplicationRecord
  belongs_to :house_season
  enum :kind, { stay_observation: 'stay_observation', bed_request: 'bed_request' }, validate: true
  validates :kind, :observed_on, :value, :source_key, presence: true
  validates :source_key, uniqueness: { scope: :house_season_id }
  validate :within_source_dates

  private

  def within_source_dates
    return unless house_season && observed_on
    return if (house_season.starts_on..house_season.ends_on).cover?(observed_on)

    errors.add(:observed_on, 'must match this source season')
  end
end
