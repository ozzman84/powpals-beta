# frozen_string_literal: true

class HouseSeasonMembership < ApplicationRecord
  belongs_to :house_season
  belongs_to :roommate
  has_one :user, through: :roommate
  enum :status, { active: 'active', former: 'former' }, prefix: true, validate: true
  validates :roommate_id, uniqueness: { scope: :house_season_id }
  validate :same_house

  private

  def same_house
    return if roommate && house_season && roommate.lodging_id == house_season.lodging_id && !roommate.guest?

    errors.add(:roommate, 'must be a roommate in this house')
  end
end
