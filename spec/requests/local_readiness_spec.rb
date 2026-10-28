# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Local readiness' do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user, city: nil, state: nil) }

  before do
    sign_in user.account
  end

  it 'renders a profile without location details' do
    get user_path
    expect(response).to have_http_status(:ok)
  end

  it 'renders the dashboard when weather is unavailable' do
    create(:resort)
    allow(WeatherService).to receive(:fetch_forecast_for_resort).and_return(nil)
    get root_path
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('forecast is unavailable')
  end

  it 'creates a house and completes a stay planning workflow' do
    post users_lodgings_path, params: { lodging: { title: 'Winter house', max_guests: 5,
                                                   season_start: Date.current, season_end: Date.current + 30 } }
    lodging = Lodging.find_by!(title: 'Winter house')
    expect(response).to redirect_to(users_lodging_path(lodging))
    expect(lodging.roommates.find_by!(user: user)).to be_lease_holder

    post users_lodging_calendars_path(lodging),
      params: { calendar: { date: Date.current, status: 'staying', guest_count: 1, cars: 1 } }
    entry = user.calendars.find_by!(lodging: lodging)
    expect(entry.guest_count).to eq(1)
    patch users_lodging_calendars_path(lodging, id: entry.id),
      params: { calendar: { status: 'away', guest_count: 0, cars: 0 } }
    expect(entry.reload).to be_away

    [users_lodging_path(lodging), users_lodging_calendars_path(lodging),
      my_calendar_users_lodging_calendars_path(lodging), users_lodging_rooms_path(lodging)].each do |path|
      get path
      expect(response).to have_http_status(:ok)
    end

    delete users_lodging_calendars_path(lodging, id: entry.id)
    expect(user.calendars.where(id: entry.id)).not_to exist
  end
end
