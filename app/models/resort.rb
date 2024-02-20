# frozen_string_literal: true

class Resort < ApplicationRecord
  has_many :account_ski_days
  has_many :accounts, through: :account_ski_days
  has_many :season_pass_resorts
  has_many :season_passes, through: :season_pass_resorts
  has_many :blackout_days

  def skier_count_for_date(date = Date.today)
    account_ski_days.where(start_date: date).count
  end

  def next_10_day_skier_count
    # start_date = Date.today
    end_date = 8.days.from_now

    (Date.today..end_date).each_with_object({}) do |date, counts|
      counts[date] = skier_count_for_date(date)
    end
  end
end
