# frozen_string_literal: true

FactoryBot.define do
  factory :account_season_pass do
    account
    season_pass
    starts_on { Date.current.beginning_of_year }
    expires_on { Date.current.end_of_year }
    season_label { Date.current.year.to_s }
  end
end
