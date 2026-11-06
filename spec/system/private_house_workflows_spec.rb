# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Private house workflows on a phone' do
  let(:manager) { create(:user, full_name: 'House Manager') }
  let(:accountant) { create(:user, full_name: 'House Accountant') }
  let(:guest) { create(:user, full_name: 'Invited Visitor') }
  let(:house) do
    create(:lodging, title: 'Private winter house', season_start: Date.current, season_end: Date.current + 30)
  end

  let(:season) do
    house.house_seasons.create!(name: 'Current winter', starts_on: house.season_start, ends_on: house.season_end,
      policy_status: :confirmed, guest_rates: Date::DAYNAMES.index_with { 5000 })
  end

  before do
    member = create(:roommate, user: manager, lodging: house, role: :admin)
    create(:roommate, user: accountant, lodging: house, role: :accountant)
    season.house_season_memberships.create!(roommate: member)
    house.rooms.create!(name: 'Main bedroom').beds.create!(size: :queen, label: 'Main queen')
    page.current_window.resize_to(390, 844)
    login_as manager.account, scope: :account
  end

  it 'requests a named guest, reviews beds, posts a charge and shows only the guests own stay' do
    visit users_lodging_guest_stays_path(house)
    fill_in 'Guest name', with: 'Invited Visitor'
    fill_in 'Guest email', with: guest.account.email
    fill_in 'Arrival', with: Date.current.iso8601
    fill_in 'Departure (checkout)', with: (Date.current + 2).iso8601
    click_on 'Request guest stay'
    expect(page).to have_content('Invited Visitor')
    expect(page.evaluate_script('document.documentElement.scrollWidth <= window.innerWidth')).to be(true)
    select 'approved', from: 'Status'
    click_on 'Update guest stay'
    expect(house.guest_stays.last).to be_approved
    click_on 'Bed requests'
    select 'Main bedroom: Main queen', from: 'Sleeping space'
    fill_in 'Arrival', with: Date.current.iso8601
    fill_in 'Departure (checkout)', with: (Date.current + 2).iso8601
    click_on 'Request bed'
    expect(page).to have_content('This is not a confirmed assignment')
    click_on 'Members'
    expect(page).to have_content('Seasonal member directory')
    page.save_screenshot(Rails.root.join('tmp/phone-season-directory.png')) # rubocop:disable Lint/Debugger
    expect(page.evaluate_script('document.documentElement.scrollWidth <= window.innerWidth')).to be(true)
    login_as accountant.account, scope: :account
    visit users_lodging_guest_stays_path(house)
    click_on 'Post guest charges'
    expect(page).to have_content('Guest charges posted once by month')
    stay = house.guest_stays.last
    stay.accept!(guest.account)
    login_as guest.account, scope: :account
    visit guest_visit_path(stay)
    expect(page).to have_content('Outstanding: $100.00')
    expect(page).to have_no_link('My houses')
    expect(page).to have_no_content('Record payment')
    expect(page.evaluate_script('document.documentElement.scrollWidth <= window.innerWidth')).to be(true)
  end
end
