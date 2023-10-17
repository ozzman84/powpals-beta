# frozen_string_literal: true

FactoryBot.define do
  factory :bed do
    room { nil }
    style { 'MyString' }
    size { 'MyString' }
  end
end
