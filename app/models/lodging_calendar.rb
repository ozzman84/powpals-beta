# frozen_string_literal: true

class LodgingCalendar < ApplicationRecord
  belongs_to :user
  belongs_to :lodging

  validates :start_date, uniqueness: { scope: %i[lodging_id user_id], message: 'A user cannot have a duplicate start_date for a lodging' }

  enum status: {
    away: 'away',
    overnight: 'overnight',
    undecided: 'undecided'
  }

  def color_by_status
    case status
    when 'overnight'
      'text-white bg-green-900'
    when 'away'
      'text-white bg-red-500'
    else
      'text-gray-400'
    end
  end

  def next_status
    case status
    when nil || 'undecided'
      'overnight'
    when 'overnight'
      'away'
    end
  end
end
