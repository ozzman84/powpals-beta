# frozen_string_literal: true

class Resort < ApplicationRecord
  has_many :account_ski_days, dependent: :destroy
  has_many :accounts, through: :account_ski_days
  has_many :season_pass_resorts, dependent: :destroy
  has_many :season_passes, through: :season_pass_resorts
  has_many :blackout_days, dependent: :destroy

  validates :name, uniqueness: { case_sensitive: false }
  validates :name, presence: true, length: { maximum: 100, case_sensitive: false }
  validates :city, :state, presence: true, length: { maximum: 50, case_sensitive: false }

  def skier_count_for_date(date = Date.today)
    account_ski_days.where(start_date: date).count
  end

  def next_10_day_skier_count
    end_date = 9.days.from_now

    (Date.today..end_date).each_with_object({}) do |date, counts|
      counts[date] = skier_count_for_date(date)
    end
  end
end
