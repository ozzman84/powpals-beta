# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'House fees on a phone' do
  let(:user) { create(:user) }
  let(:house) { create(:lodging, title: 'Winter house') }
  let(:season) do
    house.house_seasons.create!(name: 'Winter season', starts_on: '2026-11-01', ends_on: '2027-04-30')
  end

  before do
    create(:roommate, user: user, lodging: house, role: :lease_holder)
    login_as user.account, scope: :account
    page.current_window.resize_to(390, 844)
  end

  it 'confirms rates, estimates nights and records a partial payment without moving money' do
    visit users_lodging_house_season_path(house, season)
    select 'Confirmed', from: 'Policy status'
    weekdays = %w[Monday Tuesday Wednesday]
    Date::DAYNAMES.each do |day|
      fill_in day, with: (weekdays.include?(day) ? '30' : '50')
    end
    fill_in 'House rules and departure checklist', with: 'Members have bed priority. Finish laundry before leaving.'
    click_on 'Save season policy'
    expect(page).to have_content('Policy: Confirmed')
    fill_in 'Arrival', with: '2026-11-04'
    fill_in 'Checkout', with: '2026-11-07'
    fill_in 'Guests', with: 2
    click_on 'Estimate guest fees'
    expect(page).to have_content('Guest-fee estimate: $260.00')
    expect(HouseLedgerEntry.count).to eq(0)
    fill_in 'Description', with: 'Weekend guest fees'
    fill_in 'Amount (USD)', with: '100'
    click_on 'Add ledger entry'
    expect(page).to have_content('Weekend guest fees')
    fill_in 'Receipt amount (USD)', with: '40'
    fill_in 'Payment date', with: '2026-11-10'
    click_on 'Record payment'
    expect(page).to have_content('Payment recorded. No money was transferred.')
    expect(page).to have_content('Outstanding: $60.00')
    expect(page.evaluate_script('document.documentElement.scrollWidth <= window.innerWidth')).to be(true)
    page.save_screenshot(Rails.root.join('tmp/phone-house-finances.png')) # rubocop:disable Lint/Debugger
  end
end
