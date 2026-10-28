# frozen_string_literal: true

class Roommate < ApplicationRecord
  belongs_to :user
  belongs_to :lodging

  validates :user_id, uniqueness: { scope: :lodging_id, message: 'This person is already a roommate.' }

  enum :role, {
    roommate: 'roommate',
    admin: 'admin',
    accountant: 'accountant',
    lease_holder: 'lease holder',
    secratary: 'secratary',
    guest: 'guest'
  }, default: 'roommate', validate: true
end
