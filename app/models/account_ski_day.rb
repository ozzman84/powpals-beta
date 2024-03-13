# frozen_string_literal: true

class AccountSkiDay < ApplicationRecord
  belongs_to :account
  belongs_to :resort

  validates :start_date, uniqueness: { scope: %i[account_id resort_id] }
end
