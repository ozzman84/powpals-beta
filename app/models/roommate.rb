# frozen_string_literal: true

class Roommate < ApplicationRecord
  belongs_to :user
  belongs_to :lodging
  has_many :house_season_memberships, dependent: :restrict_with_error
  enum :access_state, { active: 'active', revoked: 'revoked' }, prefix: :access, validate: true

  scope :accessible, lambda {
    managed = HouseSeasonMembership.select(:roommate_id)
    current = HouseSeasonMembership.joins(house_season: :lodging).where(status: 'active')
      .where(<<~SQL.squish).select(:roommate_id)
        (house_seasons.starts_on = lodgings.season_start AND house_seasons.ends_on = lodgings.season_end)
        OR (lodgings.season_start IS NULL AND house_seasons.id = (
          SELECT latest.id FROM house_seasons latest WHERE latest.lodging_id = lodgings.id
          ORDER BY latest.starts_on DESC, latest.id DESC LIMIT 1))
      SQL
    eligible = where(access_state: 'active').where.not(role: 'guest')
    eligible.where.not(id: managed).or(eligible.where(id: current))
  }

  validates :user_id, uniqueness: { scope: :lodging_id, message: 'This person is already a roommate.' }

  validates :lodging_id, uniqueness: { conditions: -> { where(role: 'accountant') } }, if: :accountant?

  def directory_name
    user.display_name
  end

  enum :role, {
    roommate: 'roommate',
    admin: 'admin',
    accountant: 'accountant',
    rent_collector: 'rent_collector',
    lease_holder: 'lease holder',
    secratary: 'secratary',
    guest: 'guest'
  }, default: 'roommate', validate: true
end
