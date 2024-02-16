# frozen_string_literal: true

class SeasonPassResort < ApplicationRecord
  belongs_to :season_pass
  belongs_to :resort
end
