class UserSeasonPass < ApplicationRecord
  belongs_to :user
  belongs_to :season_pass
end
