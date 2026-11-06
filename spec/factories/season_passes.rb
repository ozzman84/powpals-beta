# frozen_string_literal: true

FactoryBot.define do
  factory :season_pass do
    sequence(:name) { |index| "Test pass #{index}" }
  end
end
