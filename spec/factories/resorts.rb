# frozen_string_literal: true

FactoryBot.define do
  factory :resort do
    city = Faker::Address.unique.city
    name { "#{city} Ski Resort" }
    city { city }
    state { Faker::Address.state }
    lat { Faker::Address.latitude }
    long { Faker::Address.longitude }
  end
end
