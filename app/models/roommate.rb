# frozen_string_literal: true

class Roommate < ApplicationRecord
  belongs_to :user
  belongs_to :lodging
  has_many :house_season_memberships, dependent: :restrict_with_error
  enum :access_state, { active: 'active', revoked: 'revoked' }, prefix: :access, validate: true

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
