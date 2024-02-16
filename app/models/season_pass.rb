# frozen_string_literal: true

class SeasonPass < ApplicationRecord
  has_many :account_season_passes
  has_many :accounts, through: :account_season_passes
  has_many :season_pass_resorts
  has_many :resorts, through: :season_pass_resorts
  has_many :blackout_days
  has_many :blackout_resorts, through: :blackout_days, source: :resort

  def self.except_account_passes(account)
    where.not(id: account.season_passes).pluck(:name, :id)
  end
end
