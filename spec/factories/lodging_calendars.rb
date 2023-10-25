# frozen_string_literal: true

FactoryBot.define do
  factory :lodging_calendar do
    status { 'overnight' }
    start_date { Date.today }
    end_date { Date.tomorrow }
  end
end
