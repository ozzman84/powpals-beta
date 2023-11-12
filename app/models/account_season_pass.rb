# frozen_string_literal: true

class AccountSeasonPass < ApplicationRecord
  belongs_to :account
  belongs_to :season_pass
end
