# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Shared attendee stacks' do
  it 'opens people by preferred name on phones and desktops and restores focus after dismissal' do
    user = create(:user, preferred_name: 'Ozzie', full_name: 'Michael Osmonson')
    house = create(:lodging, season_start: Date.current, season_end: Date.current + 30)
    create(:roommate, user: user, lodging: house)
    create(:calendar, user: user, lodging: house, date: Date.current, status: :staying, guest_count: 2)
    season = house.house_seasons.create!(name: 'Winter', starts_on: house.season_start, ends_on: house.season_end)
    season.guest_stays.create!(host: user, guest_name: 'Invited Guest', email: 'stack@example.com',
      arrival: Date.current, departure: Date.current + 1, status: :approved)
    login_as user.account, scope: :account
    [320, 390, 1366].each do |width|
      page.current_window.resize_to(width, 1000)
      visit users_lodging_calendars_path(house)
      within("[data-calendar-date='#{Date.current + 1}']") do
        expect(page).to have_no_css('.attendee-stack-count')
        expect(page).to have_no_css('.attendee-stack-trigger')
      end
      within("[data-calendar-date='#{Date.current}']") do
        expect(page).to have_css('.attendee-stack-count', text: '4')
        find('.attendee-stack-trigger').click
        expect(page).to have_css('dialog[open]')
        within('dialog') do
          expect(page).to have_css('.attendee-dialog-person', text: 'Ozzie')
          expect(page).to have_css('.attendee-dialog-person', text: 'Invited Guest')
          expect(page).to have_content('2 additional guests')
          expect(page).to have_no_content('Michael Osmonson')
        end
        expect(page.evaluate_script('document.activeElement.closest("dialog") !== null')).to be(true)
        find('dialog button').send_keys(:escape)
        expect(page).to have_no_css('dialog[open]')
        expect(page.evaluate_script('document.activeElement.classList.contains("attendee-stack-trigger")')).to be(true)
        find('.attendee-stack-trigger').click
        click_on 'Close'
        expect(page).to have_no_css('dialog[open]')
      end
      expect(page.evaluate_script('document.documentElement.scrollWidth <= innerWidth')).to be(true)
      page.save_screenshot(Rails.root.join("tmp/attendee-calendar-#{width}.png"), full: true) # rubocop:disable Lint/Debugger
    end
  end
end
