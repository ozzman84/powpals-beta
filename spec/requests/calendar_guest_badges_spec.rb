# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Personal calendar guest badges' do
  include Devise::Test::IntegrationHelpers

  it 'combines own approved guests with additional staying guests and excludes checkout and other hosts' do
    user = create(:user)
    other = create(:user)
    house = create(:lodging, season_start: Date.current, season_end: Date.current + 30)
    [user, other].each { |person| create(:roommate, user: person, lodging: house) }
    season = house.house_seasons.create!(name: 'Winter', starts_on: house.season_start, ends_on: house.season_end)
    user.calendars.create!(lodging: house, date: Date.current, status: :staying, guest_count: 2)
    [user, other].each_with_index do |host, index|
      season.guest_stays.create!(host: host, guest_name: 'Guest', email: "badge#{index}@example.com",
        arrival: Date.current, departure: Date.current + 1, status: :approved)
    end
    sign_in user.account
    get my_calendar_users_lodging_calendars_path(house)
    expect(response.body).to include('data-guest-count="3"', 'aria-label="3 guests"')
    expect(response.body.scan('data-guest-count=').size).to eq(1)
  end

  it 'does not show stale additional guest counts on away days' do
    user = create(:user)
    house = create(:lodging)
    create(:roommate, user: user, lodging: house)
    user.calendars.create!(lodging: house, date: Date.current, status: :away, guest_count: 4)
    sign_in user.account
    get my_calendar_users_lodging_calendars_path(house)
    expect(response.body).not_to include('data-guest-count=')
  end
end
