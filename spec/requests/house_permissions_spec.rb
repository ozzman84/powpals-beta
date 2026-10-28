# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'House permissions' do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user) }
  let(:lodging) { create(:lodging) }
  let(:other_lodging) { create(:lodging) }

  before do
    Roommate.create!(user: user, lodging: lodging, role: :roommate)
    sign_in user.account
  end

  it 'forbids ordinary roommates from editing house details' do
    patch users_lodging_path(lodging), params: { lodging: { title: 'Changed' } }
    expect(response).to have_http_status(:forbidden)
    expect(lodging.reload.title).not_to eq('Changed')
  end

  it 'allows lease holders to edit their house' do
    lodging.roommates.find_by!(user: user).update!(role: :lease_holder)
    patch users_lodging_path(lodging), params: { lodging: { title: 'Changed' } }
    expect(response).to redirect_to(users_lodging_path(lodging))
    expect(lodging.reload.title).to eq('Changed')
  end

  it 'does not permit calendar entries for another house through the request body' do
    post users_lodging_calendars_path(lodging),
      params: { calendar: { date: Date.current, status: 'staying', lodging_id: other_lodging.id } }
    expect(user.calendars.last.lodging).to eq(lodging)
  end

  it 'does not permit changing another house calendar through a mismatched route' do
    entry = Calendar.create!(user: user, lodging: other_lodging, date: Date.current, status: :staying)
    expect do
      patch users_lodging_calendars_path(lodging, id: entry.id), params: { calendar: { status: 'away' } }
    end.to raise_error(ActiveRecord::RecordNotFound)
    expect(entry.reload).to be_staying
  end

  it 'forbids roommates from adding members' do
    post users_lodging_roommates_path(lodging), params: { roommate: { user_id: create(:user).id, role: 'admin' } }
    expect(response).to have_http_status(:forbidden)
  end

  it 'ignores an overridden house ID when a manager adds a member' do
    lodging.roommates.find_by!(user: user).update!(role: :admin)
    newcomer = create(:user)
    post users_lodging_roommates_path(lodging),
      params: { roommate: { user_id: newcomer.id, lodging_id: other_lodging.id, role: 'roommate' } }
    expect(newcomer.lodgings).to contain_exactly(lodging)
  end

  it 'does not allow guests to write stays' do
    lodging.roommates.find_by!(user: user).update!(role: :guest)
    post users_lodging_calendars_path(lodging), params: { calendar: { date: Date.current, status: 'staying' } }
    expect(response).to have_http_status(:forbidden)
    expect(user.calendars.reload).to be_empty
  end

  it 'creates rooms with multiple nested beds for a manager' do
    lodging.roommates.find_by!(user: user).update!(role: :lease_holder)
    post users_lodging_rooms_path(lodging), params: { room: { name: 'Main bedroom', room_type: 'bedroom',
                                                              beds_attributes: [{ size: 'twin', style: 'mattress' },
                                                                { size: 'queen', style: 'mattress' }] } }
    expect(response).to redirect_to(users_lodging_rooms_path(lodging))
    expect(lodging.rooms.last.beds.count).to eq(2)
  end

  it 'rejects invalid membership roles without a server error' do
    lodging.roommates.find_by!(user: user).update!(role: :lease_holder)
    post users_lodging_roommates_path(lodging), params: { roommate: { user_id: create(:user).id, role: 'unknown' } }
    expect(response).to have_http_status(:unprocessable_entity)
  end

  it 'reports invalid stay statuses without a server error' do
    post users_lodging_calendars_path(lodging), params: { calendar: { date: Date.current, status: 'unknown' } }
    expect(response).to redirect_to(my_calendar_users_lodging_calendars_path(lodging, start_date: Date.current))
    expect(user.calendars.reload).to be_empty
  end
end
