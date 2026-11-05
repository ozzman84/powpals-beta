# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Sleeping inventory maintenance' do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user) }
  let(:house) { create(:lodging, max_guests: nil) }
  let(:room) { house.rooms.create!(name: 'Guest room', room_type: :bedroom) }
  let(:bed) { room.beds.create!(size: :twin, style: :airmattress) }

  before do
    create(:roommate, lodging: house, user: user, role: :lease_holder)
    sign_in user.account
  end

  it 'supports labeled temporary spaces and preserves configured capacity' do
    patch users_lodging_room_bed_path(house, room, bed), params: {
      bed: { label: 'Foyer air mattress', temporary: true, capacity: 1, notes: 'Inflate before arrival' }
    }
    expect(bed.reload).to have_attributes(label: 'Foyer air mattress', temporary: true, capacity: 1)
    get users_lodging_rooms_path(house)
    expect(response.body).to include('Foyer air mattress', 'temporary', 'Inflate before arrival')
  end

  it 'prevents ordinary roommates from editing inventory or using another house bed' do
    house.roommates.find_by!(user: user).update!(role: :roommate)
    patch users_lodging_room_bed_path(house, room, bed), params: { bed: { capacity: 9 } }
    expect(response).to have_http_status(:forbidden)
    expect(bed.reload.capacity).to eq(1)
  end

  it 'supports private layout references and rejects executable links' do
    patch users_lodging_path(house), params: { lodging: { layout_reference_url: 'javascript:alert(1)' } }
    expect(house.reload.layout_reference_url).to be_nil
    patch users_lodging_path(house), params: { lodging: { layout_reference_url: 'https://example.com/layout' } }
    expect(house.reload.layout_reference_url).to eq('https://example.com/layout')
  end

  it 'lets managers add temporary sleeping spaces to an existing room' do
    post users_lodging_room_beds_path(house, room), params: {
      bed: { size: 'twin', style: 'sleeping_bag', temporary: true, label: 'Spare sleeping bag' }
    }
    expect(room.beds.last).to have_attributes(temporary: true, capacity: 1, label: 'Spare sleeping bag')
  end
end
