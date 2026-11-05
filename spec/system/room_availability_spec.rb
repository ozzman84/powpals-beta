# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Room availability card on phones and desktops' do
  it 'fits the overview and uses small bed and occupant icons' do
    user = create(:user, full_name: 'AlexandriaWinterhouseMontgomerySnowboarding Reviewer', avatar_url: nil)
    house = create(:lodging, season_start: Date.current, season_end: Date.current + 30)
    create(:roommate, user: user, lodging: house)
    room = house.rooms.create!(name: 'Master bedroom')
    bed = room.beds.create!(size: :queen, label: 'Master window queen')
    bed.bed_requests.create!(user: user, arrival: Date.current, departure: Date.current + 1,
      spaces: 2, status: :confirmed)
    room.beds.create!(size: :twin, style: :bunk, label: 'Upper bunk')
    login_as user.account, scope: :account
    [390, 1366].each do |width|
      page.current_window.resize_to(width, 1000)
      visit users_lodging_path(house)
      within('#rooms-today') do
        expect(page).to have_content('Master window queen')
        expect(page).to have_content('Taken')
        expect(page).to have_content('Upper bunk')
        expect(page).to have_content('Available')
      end
      expect(page.evaluate_script('document.documentElement.scrollWidth <= innerWidth')).to be(true)
      expect(page.evaluate_script(<<~JS)).to eq([20, 20, 24, 24])
        (() => { const b = document.querySelector('[data-bed-icon]').getBoundingClientRect();
          const a = document.querySelector('#rooms-today [data-avatar]').getBoundingClientRect();
          return [b.width, b.height, a.width, a.height]; })()
      JS
      page.save_screenshot(Rails.root.join("tmp/rooms-today-#{width}.png"), full: true) # rubocop:disable Lint/Debugger
    end
  end
end
