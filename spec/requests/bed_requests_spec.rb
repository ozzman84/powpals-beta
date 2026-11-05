# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Dated bed requests' do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user) }
  let(:other) { create(:user) }
  let(:house) { create(:lodging, season_start: Date.current, season_end: Date.current + 30) }
  let(:bed) { house.rooms.create!(name: 'Queen room', room_type: :bedroom).beds.create!(size: :queen) }
  let(:request) { bed.bed_requests.create!(user: user, arrival: Date.current, departure: Date.current + 2, spaces: 2) }

  before do
    create(:roommate, user: user, lodging: house)
    create(:roommate, user: other, lodging: house, role: :lease_holder)
    sign_in user.account
  end

  it 'records requests without allowing a roommate to self-confirm' do
    post users_lodging_bed_requests_path(house), params: {
      bed_request: { bed_id: bed.id, arrival: Date.current, departure: Date.current + 2, spaces: 2,
                     status: 'confirmed' }
    }
    expect(bed.bed_requests.last).to be_requested
    patch users_lodging_bed_request_path(house, bed.bed_requests.last),
      params: { bed_request: { status: 'confirmed' } }
    expect(response).to have_http_status(:forbidden)
  end

  it 'rejects overlapping confirmed space while allowing checkout-day reuse' do
    request.transition!('confirmed')
    overlap = bed.bed_requests.create!(user: other, arrival: Date.current + 1, departure: Date.current + 3)
    expect { overlap.transition!('confirmed') }.to raise_error(ActiveRecord::RecordInvalid)
    next_stay = bed.bed_requests.create!(user: other, arrival: Date.current + 2, departure: Date.current + 3)
    expect { next_stay.transition!('confirmed') }.not_to raise_error
  end

  it 'does not accept a forged bed from another house or cancellation by another ordinary member' do
    foreign = create(:lodging).rooms.create!(name: 'Elsewhere').beds.create!(size: :twin)
    expect do
      post users_lodging_bed_requests_path(house), params: {
        bed_request: { bed_id: foreign.id, arrival: Date.current, departure: Date.current + 1, spaces: 1 }
      }
    end.to raise_error(ActiveRecord::RecordNotFound)
    request
    house.roommates.find_by!(user: other).update!(role: :roommate)
    sign_in other.account
    patch users_lodging_bed_request_path(house, request), params: { bed_request: { status: 'cancelled' } }
    expect(response).to have_http_status(:forbidden)
  end
end
