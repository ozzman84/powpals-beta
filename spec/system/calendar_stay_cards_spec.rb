# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Calendar stay cards' do
  let(:user) { create(:user, avatar_url: nil) }
  let(:house) { create(:lodging, season_start: Date.current, season_end: Date.current + 30) }
  let!(:stay) do
    create(:calendar, user: user, lodging: house, date: Date.current, status: :staying, guest_count: 2, cars: 1)
  end

  before do
    create(:roommate, user: user, lodging: house)
    login_as user.account, scope: :account
    page.current_window.resize_to(390, 844)
  end

  it 'edits, cancels and deletes a stay through its visible options menu' do
    visit my_calendar_users_lodging_calendars_path(house)
    within("[data-stay-id='#{stay.id}']") do
      expect(page).to have_content('2 guests · 1 car')
      expect(page).to have_no_button('Save stay')
      click_on "Options for #{Date.current.strftime('%b %-d')}"
      click_on 'Edit stay'
      fill_in 'Additional unnamed guests', with: 4
      click_on 'Cancel'
      expect(page).to have_no_button('Save stay')
      click_on "Options for #{Date.current.strftime('%b %-d')}"
      click_on 'Edit stay'
      expect(find_field('Additional unnamed guests').value).to eq('2')
      fill_in 'Additional unnamed guests', with: 3
      click_on 'Save stay'
    end
    expect(stay.reload.guest_count).to eq(3)
    expect(page).to have_css('[data-guest-count="3"]')
    expect(page.evaluate_script('document.documentElement.scrollWidth <= window.innerWidth')).to be(true)
    page.save_screenshot(Rails.root.join('tmp/phone-stay-cards.png'), full: true) # rubocop:disable Lint/Debugger
    within("[data-stay-id='#{stay.id}']") do
      click_on "Options for #{Date.current.strftime('%b %-d')}"
      click_on 'Delete stay'
    end
    expect(Calendar.exists?(stay.id)).to be(false)
    expect(page).to have_content('No days recorded yet')
  end

  it 'keeps avatars square and action icons bounded at phone and desktop widths' do
    [390, 1366].each do |width|
      page.current_window.resize_to(width, 900)
      visit user_path
      expect(dimensions('[data-avatar].h-16')).to eq([64, 64])
      visit my_calendar_users_lodging_calendars_path(house)
      expect(dimensions('button[data-stay-card-target="toggle"]')).to eq([40, 40])
      expect(dimensions('button[data-stay-card-target="toggle"] svg')).to eq([20, 20])
      expect(page.evaluate_script('document.documentElement.scrollWidth <= window.innerWidth')).to be(true)
    end
    page.save_screenshot(Rails.root.join('tmp/desktop-stay-cards.png'), full: true) # rubocop:disable Lint/Debugger
  end

  def dimensions(selector)
    page.evaluate_script(<<~JS)
      (() => { const rect = document.querySelector(#{selector.to_json}).getBoundingClientRect();
        return [rect.width, rect.height]; })()
    JS
  end
end
