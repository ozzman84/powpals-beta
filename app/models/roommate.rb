# frozen_string_literal: true

class Roommate < ApplicationRecord
  belongs_to :user
  belongs_to :lodging

  validates :user_id, uniqueness: { scope: :lodging_id, message: 'This person is already a roommate.' }

  validates :lodging_id, uniqueness: { conditions: -> { where(role: 'accountant') } }, if: :accountant?

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
