# frozen_string_literal: true

FactoryBot.define do
  factory :roommate do
    role { 'roommate' }
    user
    lodging
  end
end
