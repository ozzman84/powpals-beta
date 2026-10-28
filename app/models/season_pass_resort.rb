# frozen_string_literal: true

class SeasonPassResort < ApplicationRecord
  belongs_to :season_pass
  belongs_to :resort
  validates :season_pass_id, uniqueness: { scope: :resort_id }
end
