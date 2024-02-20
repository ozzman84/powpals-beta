# frozen_string_literal: true

FactoryBot.define do
  factory :resort do
    city = Faker::Address.city
    name { "#{city} Ski Resort" }
    city { city }
    state { Faker::Address.state }
  end
end
