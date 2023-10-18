# frozen_string_literal: true

FactoryBot.define do
  factory :bed do
    style { Bed.style.keys.sample }
    size { Bed.size.keys.sample }
  end
end
