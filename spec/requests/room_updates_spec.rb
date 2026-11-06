# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Room editing boundaries' do
  include Devise::Test::IntegrationHelpers

  let(:manager) { create(:user) }
  let(:member) { create(:user) }
  let(:house) { create(:lodging) }
  let(:room) { house.rooms.create!(name: 'Main bedroom') }

  before do
    create(:roommate, user: manager, lodging: house, role: :admin)
    create(:roommate, user: member, lodging: house)
    sign_in manager.account
  end

  it 'saves valid changes and keeps the previous name on blank or case-insensitive duplicate names' do
    patch users_lodging_room_path(house, room),
      params: { room: { name: 'Window room', layout_notes: 'Queen by window' } }
    expect(room.reload).to have_attributes(name: 'Window room', layout_notes: 'Queen by window')
    expect(response).to redirect_to(users_lodging_rooms_path(house))
    ['', 'OTHER ROOM'].each do |name|
      house.rooms.find_or_create_by!(name: 'Other room')
      patch users_lodging_room_path(house, room), params: { room: { name: name } }
      expect(flash[:alert]).to be_present
      expect(room.reload.name).to eq('Window room')
    end
  end

  it 'denies ordinary members and rejects room IDs from other houses' do
    sign_in member.account
    patch users_lodging_room_path(house, room), params: { room: { name: 'Unauthorized' } }
    expect(response).to have_http_status(:forbidden)
    expect(room.reload.name).to eq('Main bedroom')
    sign_in manager.account
    foreign = create(:lodging).rooms.create!(name: 'Foreign room')
    expect do
      patch users_lodging_room_path(house, foreign), params: { room: { name: 'Unauthorized' } }
    end.to raise_error(ActiveRecord::RecordNotFound)
    expect(foreign.reload.name).to eq('Foreign room')
  end
end
