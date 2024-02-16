# frozen_string_literal: true

FactoryBot.define do
  factory :blackout_day do
    start_date { '2024-02-15' }
    end_date { '2024-02-15' }
    season_pass { nil }
    resort { nil }
  end
end
