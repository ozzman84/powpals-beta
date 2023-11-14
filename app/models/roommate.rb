# frozen_string_literal: true

class Roommate < ApplicationRecord
  belongs_to :user
  belongs_to :lodging

  validates_uniqueness_of :user_id, scope: :lodging_id, message: 'This person is already a roommate.'

  enum role: {
    roommate: 'roommate',
    admin: 'admin',
    accountant: 'accountant',
    lease_holder: 'lease holder',
    secratary: 'secratary',
    guest: 'guest'
  }
end
