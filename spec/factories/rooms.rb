# frozen_string_literal: true

FactoryBot.define do
  factory :room do
    name { %w[master guest den].sample }
  end
end
