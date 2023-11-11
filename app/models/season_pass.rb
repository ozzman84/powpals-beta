class SeasonPass < ApplicationRecord
  has_many :user_season_passes
  has_many :users, through: :user_season_passes
end
