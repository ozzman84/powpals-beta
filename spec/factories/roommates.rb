# frozen_string_literal: true

FactoryBot.define do
  factory :roommate do
    role { 'MyString' }
    user { nil }
    Lodging { nil }
  end
end
