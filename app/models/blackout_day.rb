# frozen_string_literal: true

class BlackoutDay < ApplicationRecord
  belongs_to :season_pass
  belongs_to :resort
end
