# frozen_string_literal: true

class Resort < ApplicationRecord
  has_many :account_ski_days
  has_many :accounts, through: :account_ski_days
  has_many :season_pass_resorts
  has_many :season_passes, through: :season_pass_resorts
  has_many :blackout_days
end
