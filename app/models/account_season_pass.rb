# frozen_string_literal: true

class AccountSeasonPass < ApplicationRecord
  belongs_to :account
  belongs_to :season_pass
  validates :account_id, uniqueness: { scope: :season_pass_id }
end
