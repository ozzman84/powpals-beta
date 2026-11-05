# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Named guest stays' do
  include Devise::Test::IntegrationHelpers

  let(:host) { create(:user) }
  let(:guest) { create(:user) }
  let(:house) { create(:lodging, season_start: Date.current, season_end: Date.current + 30) }
  let(:season) { house.house_seasons.create!(name: 'Winter', starts_on: house.season_start, ends_on: house.season_end) }
  let(:stay) do
    season.guest_stays.create!(host: host, guest_name: 'Example Guest', email: guest.account.email,
      arrival: Date.current, departure: Date.current + 2, cars: 1)
  end

  before do
    create(:roommate, user: host, lodging: house)
    sign_in host.account
  end

  it 'accepts only the intended guest and keeps house navigation and the roster private' do
    token = stay.token
    sign_in guest.account
    patch guest_invitation_path(token: token)
    expect(stay.reload.guest).to eq(guest)
    expect(guest.lodgings).to be_empty
    get guest_visit_path(stay)
    expect(response).to have_http_status(:ok)
    expect(response.body).not_to include('My houses', 'Roommates')
    get users_lodging_house_members_path(house)
    expect(response).to have_http_status(:forbidden)
  end

  it 'counts approved named guests once alongside additional unnamed guests and excludes checkout' do
    host.calendars.create!(lodging: house, date: Date.current, status: :staying, guest_count: 1, cars: 1)
    stay.transition!('approved')
    counts = house.calendars.this_week(lodging: house)
    expect(counts[Date.current]).to include(staying: 1, guests: 2, cars: 2)
    expect(counts[Date.current + 2][:guests]).to eq(0)
  end

  it 'does not allow hosts to approve their own guests or charge a roommate as a guest' do
    patch users_lodging_guest_stay_path(house, stay), params: { guest_stay: { status: 'approved' } }
    expect(response).to have_http_status(:forbidden)
    invalid = season.guest_stays.new(host: host, guest_name: 'Roommate', email: host.account.email,
      arrival: Date.current, departure: Date.current + 1)
    expect(invalid).not_to be_valid
  end

  it 'rejects duplicate guests and expired, cancelled or wrong-account invitations' do
    stay
    duplicate = season.guest_stays.new(host: host, guest_name: 'Duplicate', email: guest.account.email,
      arrival: Date.current, departure: Date.current + 1)
    expect(duplicate).not_to be_valid
    expect { stay.accept!(host.account) }.to raise_error(ArgumentError)
    stay.update!(expires_at: 1.minute.ago)
    expect { stay.accept!(guest.account) }.to raise_error(ArgumentError)
    stay.update!(expires_at: 1.day.from_now)
    stay.transition!('cancelled')
    expect { stay.accept!(guest.account) }.to raise_error(ArgumentError)
  end

  it 'prioritizes pending roommate bed requests ahead of guests and cancels guest assignments with the stay' do
    bed = house.rooms.create!(name: 'Room').beds.create!(size: :queen)
    stay.transition!('approved')
    member_request = bed.bed_requests.create!(user: host, arrival: Date.current, departure: Date.current + 1)
    guest_request = bed.bed_requests.create!(user: host, guest_stay: stay,
      arrival: Date.current, departure: Date.current + 1)
    expect { guest_request.transition!('confirmed') }.to raise_error(ActiveRecord::RecordInvalid)
    member_request.transition!('confirmed')
    guest_request.reload.transition!('confirmed')
    stay.transition!('cancelled')
    expect(guest_request.reload).to be_cancelled
    expect(member_request.reload).to be_confirmed
  end
end
