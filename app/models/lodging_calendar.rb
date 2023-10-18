# frozen_string_literal: true

class LodgingCalendar < ApplicationRecord
  belongs_to :user
  belongs_to :lodging

  enum status: {
    away: 'away',
    overnight: 'overnight'
  }
end
