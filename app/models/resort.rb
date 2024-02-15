class Resort < ApplicationRecord
  has_many :account_ski_days
  has_many :accounts, through: :account_ski_days
end