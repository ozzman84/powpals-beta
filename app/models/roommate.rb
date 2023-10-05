# frozen_string_literal: true

class Roommate < ApplicationRecord
  belongs_to :user
  belongs_to :lodging

  enum role: {
    roommate: 'roommate',
    admin: 'admin',
    accountant: 'accountant',
    lease_holder: 'lease holder',
    secratary: 'secratary',
    guest: 'guest'
  }
end
