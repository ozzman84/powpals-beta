class SeasonPass < ApplicationRecord
  has_many :account_season_passes
  has_many :accounts, through: :account_season_passes
end
