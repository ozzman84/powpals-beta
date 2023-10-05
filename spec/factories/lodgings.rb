# frozen_string_literal: true

FactoryBot.define do
  factory :lodging do
    title { Faker::Fantasy::Tolkien.location }
    description { Faker::Fantasy::Tolkien.poem }
    max_guests { rand(1..100) }
    street { Faker::Address.street_name }
    city { Faker::Address.city }
    state { Faker::Address.state_abbr }
    zip_code { Faker::Address.zip }
    country { 'United States' }
    lat { Faker::Address.latitude }
    lon { Faker::Address.longitude }
  end
end
