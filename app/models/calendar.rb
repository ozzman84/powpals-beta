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
  CALENDAR_LENGTH = 42

  # scope :grouped_by_date_with_avatars, ->(start_date) {
  #   where(date: build_dates(start_date))
  #     .includes(:user)
  #     .order(:date)
  #     .group_by(&:date)
  #     .transform_values { |calendars| calendars.map { |calendar| calendar.user } }
  # }

  def self.grouped_by_date_with_avatars(start_date)
    date_range = build_dates(start_date)
    calendars = where(date: date_range, status: 'staying').includes(:user)

    result_hash = {}
    date_range.each { |date| result_hash[date] = [] }

    calendars.each do |calendar|
      result_hash[calendar.date] << calendar.user.avatar_url
    end

    result_hash
  end

  def self.build_dates(start_date)
    first_date = start_date.beginning_of_month.beginning_of_week(:monday)
    last_date = first_date + CALENDAR_LENGTH.days

    (first_date...last_date).to_a
  end

  def self.fetch_records_and_dates(start_date)
    month = build_dates(start_date)
    records_within_range = where(date: month)
    existing_records = records_within_range.to_a.index_by(&:date)
    Struct.new('Date', :date, :status)

    month.map { |date| existing_records[date] || Struct::Date.new(date) }
  end
end
