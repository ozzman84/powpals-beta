# frozen_string_literal: true

FactoryBot.define do
  factory :room do
    lodging { nil }
    name { 'MyString' }
  end
end
