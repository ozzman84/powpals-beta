# frozen_string_literal: true

class Calendar < ApplicationRecord
  belongs_to :user
  belongs_to :lodging

  validates :date, :user_id, :lodging_id, presence: true
  validates :date, uniqueness: { scope: %i[lodging_id user_id], message: 'A user cannot have a duplicatedate for a lodging' }

  enum status: {
    away: 'away',
    staying: 'staying',
    undecided: 'undecided'
  }

  def self.build_dates(start_date)
    first_day = start_date.beginning_of_month.beginning_of_week(:monday)
    last_day = start_date.end_of_month.end_of_week(:monday)

    (first_day..last_day).to_a
  end

  def self.fetch_records_and_dates(start_date)
    month = build_dates(start_date)
    records_within_range = where(date: month)
    existing_records = records_within_range.to_a.index_by(&:date)
    Struct.new('Date', :date)

    month.map { |date| existing_records[date] || Struct::Date.new(date) }
  end

  # def self.month_with_calendar(start_date)
  #   Struct.new('Date', :date, :next_status, :color_by_status, :path, :status, :id) do
  #     def path(_id)
  #       users_lodging_calendars_path
  #     end
  #   end

  #   month_with_full_weeks(start_date).map do |day|
  #     Calendar.find_by(date: day) || Struct::Date.new(day, 'staying', day.today? ? ' text-indigo-600 font-semibold' : 'text-gray-400')
  #   end
  # end
end
