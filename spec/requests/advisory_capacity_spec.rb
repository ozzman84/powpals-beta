# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Advisory house capacity' do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user) }
  let(:house) { create(:lodging, max_guests: nil, max_cars: 1) }

  before do
    create(:roommate, lodging: house, user: user)
    room = Room.create!(lodging: house, name: 'Room', room_type: :bedroom)
    room.beds.create!(size: :queen, style: :mattress, capacity: 2)
    room.beds.create!(size: :twin, style: :mattress, capacity: 1)
    sign_in user.account
  end

  it 'derives bed spaces and saves over-capacity stays with warnings rather than hard rejection' do
    expect(house.advisory_capacity).to eq(3)
    post users_lodging_calendars_path(house), params: {
      calendar: { date: Date.current, status: 'staying', guest_count: 5, cars: 2 }
    }
    expect(user.calendars.last).to have_attributes(guest_count: 5, cars: 2)
    follow_redirect!
    expect(response.body).to include('Sleeping guidance exceeded', 'Parking guidance exceeded')
  end

  it 'preserves explicitly configured bed space overrides' do
    bed = house.rooms.first.beds.first
    bed.update!(capacity: 4)
    expect(bed.reload.capacity).to eq(4)
    expect(house.bed_spaces).to eq(5)
  end

  it 'uses size defaults for legacy beds without stored capacity' do
    bed = house.rooms.first.beds.find_by!(size: :queen)
    # Legacy imports predate capacity validation.
    bed.update_column(:capacity, nil) # rubocop:disable Rails/SkipsModelValidations
    expect(house.bed_spaces).to eq(3)
  end

  it 'continues to reject invalid negative counts' do
    post users_lodging_calendars_path(house), params: {
      calendar: { date: Date.current, status: 'staying', guest_count: -1, cars: 0 }
    }
    expect(user.calendars.count).to eq(0)
  end
end
