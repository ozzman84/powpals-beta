# frozen_string_literal: true

FactoryBot.define do
  factory :calendar do
    status { 'staying' }
    date { Date.today }
  end
end
