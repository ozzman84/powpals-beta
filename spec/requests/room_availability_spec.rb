# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'House overview bed availability' do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user, full_name: 'Confirmed Roommate') }
  let(:house) { create(:lodging, season_start: Date.current - 5, season_end: Date.current + 30) }
  let(:room) { house.rooms.create!(name: 'Main bedroom') }
  let(:bed) { room.beds.create!(size: :queen, label: 'Window queen') }

  before do
    create(:roommate, user: user, lodging: house)
    sign_in user.account
  end

  it 'shows partial and full occupancy with occupant icons and names' do
    request = bed.bed_requests.create!(user: user, arrival: Date.current, departure: Date.current + 1)
    request.transition!('confirmed')
    get users_lodging_path(house)
    card = Nokogiri::HTML(response.body).at_css("[data-bed-availability='#{bed.id}']")
    expect(card.text).to include('Partly taken', '1 of 2 spaces free', 'Confirmed Roommate')
    expect(card.at_css('[data-bed-icon]')).to be_present
    expect(card.at_css('[data-avatar]')).to be_present
    second = bed.bed_requests.create!(user: user, arrival: Date.current, departure: Date.current + 1)
    second.transition!('confirmed')
    get users_lodging_path(house)
    expect(Nokogiri::HTML(response.body).at_css("[data-bed-availability='#{bed.id}']").text)
      .to include('Taken', '0 of 2 spaces free')
  end

  it 'does not count pending, cancelled, future or checkout-day requests as occupied tonight' do
    past = bed.bed_requests.create!(user: user, arrival: Date.current - 1, departure: Date.current, spaces: 2)
    past.transition!('confirmed')
    future = bed.bed_requests.create!(user: user, arrival: Date.current + 1, departure: Date.current + 2)
    future.transition!('confirmed')
    bed.bed_requests.create!(user: user, arrival: Date.current, departure: Date.current + 1)
    cancelled = bed.bed_requests.create!(user: user, arrival: Date.current, departure: Date.current + 1)
    cancelled.transition!('cancelled')
    get users_lodging_path(house)
    card = Nokogiri::HTML(response.body).at_css("[data-bed-availability='#{bed.id}']")
    expect(card.text).to include('Available', '2 of 2 spaces free', '1 pending request')
    expect(card.text).not_to include('Confirmed Roommate')
  end

  it 'identifies a guest occupant rather than claiming that the host occupies their bed' do
    season = house.house_seasons.create!(name: 'Winter', starts_on: house.season_start, ends_on: house.season_end)
    guest = season.guest_stays.create!(host: user, guest_name: 'Invited Skier', email: 'guest-bed@example.com',
      arrival: Date.current, departure: Date.current + 1, status: :approved)
    request = bed.bed_requests.create!(user: user, guest_stay: guest, arrival: Date.current,
      departure: Date.current + 1, spaces: 2)
    request.transition!('confirmed')
    get users_lodging_path(house)
    card = Nokogiri::HTML(response.body).at_css("[data-bed-availability='#{bed.id}']")
    expect(card.text).to include('Invited Skier (guest)', 'Taken')
    expect(card.text).not_to include('Confirmed Roommate')
  end

  it 'shows daily capacity guidance and identifiable attendees without blocking over-capacity stays' do
    house.update!(max_guests: 2)
    create(:calendar, user: user, lodging: house, date: Date.current, status: :staying, guest_count: 2)
    get users_lodging_path(house)
    day = Nokogiri::HTML(response.body).at_css("[data-attendance-date='#{Date.current}']")
    expect(day.text).to include('Today', '1 staying', '2 guests', '0 available', 'Sleeping guidance exceeded')
    expect(day.at_css('.attendance-total').text).to eq('3')
    expect(day.at_css('button[aria-label="Confirmed Roommate"]')).to be_present
    expect(day.at_css('.attendance-members')['style']).to include('33.333')
    expect(Nokogiri::HTML(response.body).css('#weekly-attendance-heading').size).to eq(1)
  end

  it 'keeps an unknown capacity readable without dividing by zero' do
    house.update!(max_guests: nil)
    get users_lodging_path(house)
    day = Nokogiri::HTML(response.body).at_css("[data-attendance-date='#{Date.current}']")
    expect(day.text).to include('Capacity not set')
    expect(day.at_css('.attendance-members')['style']).to eq('width: 0.0%')
  end
end
