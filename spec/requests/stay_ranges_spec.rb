# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Stay ranges' do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user) }
  let(:house) { create(:lodging, season_start: Date.current, season_end: Date.current + 30) }

  before do
    create(:roommate, user: user, lodging: house)
    sign_in user.account
  end

  it 'adds occupied nights with counts, excludes checkout and preserves existing days on repeat submission' do
    original = user.calendars.create!(lodging: house, date: Date.current + 1, status: :away, cars: 3)
    values = { arrival: Date.current, checkout: Date.current + 3, status: 'staying', guest_count: 2, cars: 1 }
    2.times { post users_lodging_calendars_path(house), params: { calendar: values } }
    expect(user.calendars.order(:date).pluck(:date)).to eq((Date.current...(Date.current + 3)).to_a)
    expect(original.reload).to have_attributes(status: 'away', cars: 3, guest_count: 0)
    expect(user.calendars.staying.pluck(:guest_count, :cars)).to all(eq([2, 1]))
  end

  it 'rejects reversed, out-of-season and invalid-count ranges without partial writes' do
    [{ arrival: Date.current + 2, checkout: Date.current },
      { arrival: Date.current + 29, checkout: Date.current + 32 },
      { arrival: Date.current, checkout: Date.current + 2, guest_count: -1 }].each do |values|
      post users_lodging_calendars_path(house), params: { calendar: values.merge(status: 'staying') }
      expect(user.calendars).to be_empty
      expect(flash[:alert]).to be_present
    end
  end

  it 'supports a blank checkout as one night and accepts the final rental night' do
    post users_lodging_calendars_path(house), params: {
      calendar: { arrival: house.season_end, checkout: '', status: 'staying' }
    }
    expect(user.calendars.pluck(:date)).to eq([house.season_end])
  end
end
