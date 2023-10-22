# frozen_string_literal: true

class Lodging < ApplicationRecord
  has_many :roommates
  has_many :users, through: :roommates
  has_many :rooms
  has_many :lodging_calendars

  #   validates :max_capacity, numericality: { greater_than: 0, less_than: 101 }, if: { status: :published}

  enum status: {
    draft: 'draft',
    published: 'published',
    archived: 'archived'
  }, _default: 'draft'

  def month
    # binding.pry
    first_day = Date.today.beginning_of_month.beginning_of_week(:monday)
    last_day = Date.today.end_of_month.end_of_week(:monday)

    (first_day..last_day).to_a
  end

  def current_user_dates
    lodging_calendars.where(user: current_user, start_date: month)
  end

  def combined_month
    month.map do |day|
      LodgingCalendar.find_by(start_date: day) || day
    end
  end
end
