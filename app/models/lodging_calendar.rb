# frozen_string_literal: true

class LodgingCalendar < ApplicationRecord
  belongs_to :user
  belongs_to :lodging
  belongs_to :bed

  enum status: {
    away: 'away',
    overnight: 'overnight'
  }
end
