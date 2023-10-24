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

  def month(start_date = Date.today)
    first_day = start_date.beginning_of_month.beginning_of_week(:monday)
    last_day = start_date.end_of_month.end_of_week(:monday)

    (first_day..last_day).to_a
  end

  def current_user_dates
    lodging_calendars.where(user: current_user, start_date: month)
  end

  def combined_month
    Struct.new("Date", :start_date, :end_date, :method, :next_status, :color_by_status, :path, :status, :id) do

      def path(_id)
        users_lodging_lodging_calendars_path
      end
    end

    month.map do |day|
      LodgingCalendar.find_by(start_date: day) || Struct::Date.new(day, day, :post, 'overnight', day.today? ? " text-indigo-600 font-semibold" : "text-gray-400")
    end
  end
end
