# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Restored PowPals screens' do
  let(:user) do
    create(:user, first_name: 'Alex', last_name: 'Rider', preferred_name: 'Alex',
      full_name: 'Alex Rider', city: 'Frisco', state: 'CO', about: 'Ski days with friends')
  end

  let(:house) do
    create(:lodging, title: 'Winter house', max_guests: 8, max_cars: 4,
      season_start: Date.current, season_end: Date.current + 30)
  end

  before do
    create(:roommate, user: user, lodging: house, role: :lease_holder)
    login_as user.account, scope: :account
  end

  it 'restores branded desktop navigation, profile details, passes, resorts and room cards' do
    pass = create(:season_pass)
    resort = create(:resort, name: 'Winter Park')
    create(:account_season_pass, account: user.account, season_pass: pass)
    SeasonPassResort.create!(season_pass: pass, resort: resort)
    room = Room.create!(lodging: house, name: 'Master suite', room_type: :bedroom)
    room.beds.create!(size: :queen, style: :mattress)
    page.current_window.resize_to(1366, 1000)
    visit user_path
    expect(page).to have_css('img[alt="PowPals"]')
    expect(page).to have_content('Ski days with friends')
    expect(page).to have_content(pass.name)
    expect(page).to have_content('Winter Park')
    click_on 'Winter house'
    expect(page).to have_content('Master suite')
    expect(page).to have_content('Activities')
    click_on 'Rooms'
    expect(page).to have_content('Queen Mattress')
    page.save_screenshot(Rails.root.join('tmp/restored-desktop-rooms.png')) # rubocop:disable Lint/Debugger
  end

  it 'restores phone month-grid toggles without losing guest and car controls or mobile navigation' do
    page.current_window.resize_to(390, 844)
    visit my_calendar_users_lodging_calendars_path(house)
    expect(page).to have_css('[data-testid="personal-month-grid"]')
    within("[data-calendar-date='#{Date.current.iso8601}']") { click_on Date.current.day.to_s }
    expect(user.calendars.find_by!(lodging: house, date: Date.current)).to be_staying
    expect(page).to have_button('Save stay')
    page.save_screenshot(Rails.root.join('tmp/restored-phone-calendar.png')) # rubocop:disable Lint/Debugger
    within("[data-calendar-date='#{Date.current.iso8601}']") { click_on Date.current.day.to_s }
    expect(user.calendars.find_by!(lodging: house, date: Date.current)).to be_away
    within("[data-calendar-date='#{Date.current.iso8601}']") { click_on Date.current.day.to_s }
    expect(user.calendars.where(lodging: house, date: Date.current)).not_to exist
    click_on 'Shared calendar'
    expect(page).to have_css('[data-testid="shared-month-grid"]')
    expect(page.evaluate_script('document.documentElement.scrollWidth <= window.innerWidth')).to be(true)
    click_on 'Open main menu'
    click_on 'My houses'
    expect(page).to have_content('Winter house')
  end

  it 'keeps historical stay colors visible while old rental dates are read-only' do
    old_date = Date.current.prev_year
    house.update!(season_start: old_date, season_end: old_date + 30)
    Calendar.create!(user: user, lodging: house, date: old_date, status: :staying)
    house.update!(season_start: Date.current, season_end: Date.current + 30)
    visit my_calendar_users_lodging_calendars_path(house, start_date: old_date)
    expect(page).to have_css('span.bg-green-900[title="Staying"]', text: old_date.day.to_s)
  end
end
