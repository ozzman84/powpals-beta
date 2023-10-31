# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    full_name = Faker::Fantasy::Tolkien.character

    full_name { full_name }
    first_name { full_name.split(' ').first }
    last_name { full_name.split(' ').first }
  end
end
