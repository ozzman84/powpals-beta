# frozen_string_literal: true

FactoryBot.define do
  factory :season_pass do
    name { Faker::CryptoCoin.coin_name }
  end
end
