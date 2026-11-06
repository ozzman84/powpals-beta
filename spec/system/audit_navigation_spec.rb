# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Audit navigation and room forms' do
  let(:manager) do
    create(:user, first_name: 'AlexandriaWinterhouseMontgomerySnowboarding', last_name: 'Reviewer',
      full_name: 'AlexandriaWinterhouseMontgomerySnowboarding Reviewer')
  end

  let(:house) { create(:lodging, season_start: Date.current, season_end: Date.current + 30) }
  let(:season) do
    house.house_seasons.create!(name: 'Winter review', starts_on: house.season_start, ends_on: house.season_end)
  end

  before do
    member = create(:roommate, user: manager, lodging: house, role: :lease_holder)
    season.house_season_memberships.create!(roommate: member)
    login_as manager.account, scope: :account
    page.current_window.resize_to(390, 844)
  end

  it 'adds two differently configured beds through the actual dynamic room form' do
    visit users_lodging_rooms_path(house)
    within("form[action='#{users_lodging_rooms_path(house)}']") do
      fill_in 'Name', with: 'Two bed room'
      click_on 'Add Bed'
      click_on 'Add Bed'
      all("select[name='room[beds_attributes][][size]']")[0].select('queen')
      all("select[name='room[beds_attributes][][size]']")[1].select('twin')
      all("input[name='room[beds_attributes][][label]']")[0].set('Queen main')
      all("input[name='room[beds_attributes][][label]']")[1].set('Temporary twin')
      all("input[name='room[beds_attributes][][temporary]']")[1].check
      click_on 'Add Room'
    end
    beds = house.rooms.find_by!(name: 'Two bed room').beds.order(:id)
    expect(beds.pluck(:size, :temporary, :label)).to eq([
      ['queen', false, 'Queen main'], ['twin', true, 'Temporary twin']
    ])
  end

  it 'keeps the principal manager pages inside the phone viewport', :aggregate_failures do
    paths = [user_path, edit_user_path, edit_profile_path, users_lodgings_path, users_lodging_path(house),
      edit_users_lodging_path(house), users_lodging_rooms_path(house), users_lodging_calendars_path(house),
      my_calendar_users_lodging_calendars_path(house), users_lodging_house_members_path(house),
      users_lodging_bed_requests_path(house), users_lodging_guest_stays_path(house),
      users_lodging_house_season_path(house, season), users_lodging_my_payments_path(house)]
    paths.each do |path|
      visit path
      overflow = page.evaluate_script(<<~JS)
        Array.from(document.querySelectorAll('body *')).filter(e => {
          const r = e.getBoundingClientRect(); return r.width > 0 && r.right > innerWidth + 1;
        }).slice(-8).map(e => ({tag: e.tagName, cls: e.className, text: (e.innerText || '').slice(0, 70)}))
      JS
      expect(page.evaluate_script('document.documentElement.scrollWidth <= window.innerWidth')).to be(true),
        "#{path}: #{overflow}"
    end
  end

  it 'makes profile cancellation work and marks unfinished photo upload as unavailable' do
    visit edit_user_path
    expect(page).to have_button('Change', disabled: true)
    click_on 'Cancel'
    expect(page).to have_current_path(user_path)
  end

  it 'opens the phone menu, follows house navigation and signs out without a missing avatar' do
    manager.update!(avatar_url: nil)
    visit user_path
    click_on 'Open main menu'
    within('#mobile-menu') do
      expect(page).to have_no_css('img[src=""]')
      click_on 'My houses'
    end
    expect(page).to have_current_path(users_lodgings_path)
    click_on 'Open main menu'
    within('#mobile-menu') { click_on 'Sign out' }
    expect(page).to have_current_path(new_account_session_path)
    expect(page).to have_button('Sign in')
  end
end
