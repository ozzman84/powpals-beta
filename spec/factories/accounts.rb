# frozen_string_literal: true

FactoryBot.define do
  factory :account do
    email { Faker::Internet.email(domain: 'test.com') }
    password { 'password1' }
    confirmed_at { 1.day.ago }
    confirmation_sent_at { 2.days.ago }
    sign_in_count { (2..35).to_a.sample }
  end
end
