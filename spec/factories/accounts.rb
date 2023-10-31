# frozen_string_literal: true

FactoryBot.define do
  factory :account do
    email { Faker::Internet.email(domain: 'test.com') }
    password { 'password1' }
    confirmed_at { 1.day.ago }
  end
end
