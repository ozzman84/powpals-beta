class SeasonPass < ApplicationRecord
  has_many :account_season_passes
  has_many :accounts, through: :account_season_passes

  def self.except_account_passes(account)
    where.not(id: account.season_passes).pluck(:name, :id)
  end
end
