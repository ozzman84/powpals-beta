# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email(domain: 'test.com') }
    password { 'password1' }
    full_name = Faker::Fantasy::Tolkien.character

    full_name { full_name }
    first_name { full_name.split(' ').first }
    last_name { full_name.split(' ').first }
    confirmed_at { 1.day.ago }
  end
end
