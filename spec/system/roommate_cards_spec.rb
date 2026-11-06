# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Roommate portrait cards' do
  it 'fits portraits and four desktop columns while preserving member editing on phones' do
    house = create(:lodging, season_start: Date.current, season_end: Date.current + 30)
    season = house.house_seasons.create!(name: 'Winter', starts_on: house.season_start, ends_on: house.season_end)
    people = Array.new(4) { |index| create(:user, preferred_name: "Roommate #{index}", avatar_url: nil) }
    people.each do |person|
      roommate = create(:roommate, user: person, lodging: house)
      season.house_season_memberships.create!(roommate: roommate)
    end
    login_as people.first.account, scope: :account
    [390, 1366].each do |width|
      page.current_window.resize_to(width, 1000)
      visit users_lodging_house_members_path(house)
      expect(page).to have_css('.roommate-card', count: 4)
      expect(page.evaluate_script(<<~JS)).to eq(width == 390 ? 1 : 4)
        getComputedStyle(document.querySelector('.roommate-grid')).gridTemplateColumns.split(' ').length
      JS
      expect(page.evaluate_script(<<~JS)).to eq([128, 128])
        (() => { const avatar = document.querySelector('.roommate-portrait [data-avatar]').getBoundingClientRect();
          return [avatar.width, avatar.height]; })()
      JS
      within('.roommate-card', text: 'Roommate 0') do
        find('summary', text: 'Edit member details').click
        fill_in 'Optional preferences: games, drinks, colors or other details', with: 'Board games'
        click_on 'Save member details'
      end
      expect(page).to have_content('Board games')
      expect(page.evaluate_script('document.documentElement.scrollWidth <= innerWidth')).to be(true)
      page.save_screenshot(Rails.root.join("tmp/roommate-cards-#{width}.png"), full: true) # rubocop:disable Lint/Debugger
    end
  end
end
