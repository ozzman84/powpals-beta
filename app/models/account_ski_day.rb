class AccountSkiDay < ApplicationRecord
  belongs_to :account
  belongs_to :resort
end