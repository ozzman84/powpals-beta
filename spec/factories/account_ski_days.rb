# frozen_string_literal: true

FactoryBot.define do
  factory :account_ski_day do
    status { 'MyString' }
    start_date { Date.today }
  end
end
