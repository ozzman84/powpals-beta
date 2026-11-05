# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'House planning on a phone' do
  let(:user) { create(:user) }
  let(:lodging) do
    create(:lodging, title: 'Winter house', max_guests: 5, season_start: Date.current, season_end: Date.current + 30)
  end

  before do
    Roommate.create!(user: user, lodging: lodging, role: :lease_holder)
    login_as user.account, scope: :account
    page.current_window.resize_to(390, 844)
  end

  it 'lets a roommate record guests and cars and see shared occupancy' do
    visit users_lodging_path(lodging)
    click_on 'My stays'
    find('summary', text: 'Add a stay').click
    fill_in 'Date', with: Date.current.iso8601
    fill_in 'Additional unnamed guests', with: 1
    fill_in 'Cars', with: 1
    click_on 'Add stay'
    expect(page).to have_button("Options for #{Date.current.strftime('%b %-d')}")
    within('[data-testid="personal-month-grid"]') do
      expect(page).to have_css('[data-guest-count="1"]', text: '1')
    end
    page.save_screenshot(Rails.root.join('tmp/phone-calendar-guest-badges.png'), full: true) # rubocop:disable Lint/Debugger
    click_on 'House overview'
    expect(page).to have_content('This week')
    expect(page).to have_content('Winter house')
    expect(page.evaluate_script('window.innerWidth')).to eq(390)
    expect(page.evaluate_script('document.documentElement.scrollWidth <= window.innerWidth')).to be(true)
    # Capture the verified mobile layout for visual review.
    page.save_screenshot(Rails.root.join('tmp/phone-house-overview.png')) # rubocop:disable Lint/Debugger
    click_on 'Shared calendar'
    expect(page).to have_content('1 staying')
  end
end
