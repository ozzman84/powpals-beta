# frozen_string_literal: true

class Calendar < ApplicationRecord
  belongs_to :user
  belongs_to :lodging

  validates :date, presence: true
  validates :date,
    uniqueness: { scope: %i[lodging_id user_id], message: 'A user cannot have a duplicatedate for a lodging' }

  enum :status, {
    away: 'away',
    staying: 'staying',
    undecided: 'undecided'
  }, validate: true
  validates :status, presence: true
  validates :guest_count, :cars, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  before_validation :default_counts
  validate :within_season
  validate :within_capacity

  CALENDAR_LENGTH = 42

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

  def self.this_week
    (Date.current..6.days.from_now.to_date).to_h do |day|
      entries = where(date: day).includes(:user).to_a
      staying = entries.select(&:staying?)
      [day, { away: entries.count(&:away?), staying: staying.size,
              guests: staying.sum { |entry| entry.guest_count.to_i },
              cars: staying.sum { |entry| entry.cars.to_i },
              avatar_urls: staying.filter_map { |entry| entry.user.avatar_url } }]
    end
  end

  def seven_days
    (Date.current..6.days.from_now).to_a
  end

  private

  def default_counts
    self.guest_count ||= 0
    self.cars ||= 0
  end

  def within_season
    return unless lodging && date

    errors.add(:date, 'is before the rental season') if lodging.season_start && date < lodging.season_start
    errors.add(:date, 'is after the rental season') if lodging.season_end && date > lodging.season_end
  end

  def within_capacity
    return unless staying? && lodging && date && guest_count.to_i >= 0 && cars.to_i >= 0

    others = lodging.calendars.staying.where(date: date).where.not(id: id)
    occupants = others.count + others.sum(:guest_count) + 1 + guest_count.to_i
    errors.add(:base, 'House capacity would be exceeded') if lodging.max_guests && occupants > lodging.max_guests
    return unless lodging.max_cars && others.sum(:cars) + cars.to_i > lodging.max_cars

    errors.add(:cars, 'exceed available parking')
  end
end
