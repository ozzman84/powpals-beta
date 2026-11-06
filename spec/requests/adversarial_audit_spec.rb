# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Adversarial audit' do
  include Devise::Test::IntegrationHelpers

  let(:manager) { create(:user) }
  let(:person) { create(:user) }
  let(:house) { create(:lodging, season_start: '2026-11-01', season_end: '2027-04-30') }
  let(:season) do
    house.house_seasons.create!(name: 'Winter', starts_on: house.season_start, ends_on: house.season_end)
  end

  before do
    create(:roommate, user: manager, lodging: house, role: :lease_holder)
    sign_in manager.account
  end

  it 'does not regrant a former member access when the house is rolled into a new season' do
    member = create(:roommate, user: person, lodging: house)
    season.house_season_memberships.create!(roommate: member, status: :former)
    expect(person.house_access?).to be(false)
    house.update!(season_start: '2027-11-01', season_end: '2028-04-30')
    expect(person.reload.house_access?).to be(false)
  end

  it 'does not allow an inactive former manager to satisfy last-manager protection' do
    former = create(:roommate, user: person, lodging: house, role: :admin)
    season.house_season_memberships.create!(roommate: former, status: :former)
    member = house.roommates.find_by!(user: manager)
    patch users_lodging_roommate_path(house, member), params: { roommate: { role: 'roommate' } }
    expect(member.reload).to be_lease_holder
  end

  it 'validates an empty invitation email with a user-facing message instead of a 404' do
    post users_lodging_roommates_path(house), params: { roommate: { email: '', role: 'roommate' } }
    expect(response).to have_http_status(:redirect)
    expect(flash[:alert]).to be_present
  end

  it 'does not save overlapping pass terms in one nested request' do
    pass = create(:season_pass)
    patch edit_profile_path, params: { account: { account_season_passes_attributes: {
      '0' => { season_pass_id: pass.id, season_label: 'A', starts_on: '2026-11-01', expires_on: '2027-04-30' },
      '1' => { season_pass_id: pass.id, season_label: 'B', starts_on: '2026-12-01', expires_on: '2027-03-30' }
    } } }
    expect(manager.account.account_season_passes.count).to be <= 1
  end

  it 'reports a blocked room removal without erasing assignments' do
    room = house.rooms.create!(name: 'Assigned room')
    bed = room.beds.create!(size: :queen)
    bed.bed_requests.create!(user: manager, arrival: '2026-11-10', departure: '2026-11-12')
    delete users_lodging_room_path(house, room)
    expect(room.reload).to be_present
    expect(flash[:alert]).to be_present
  end

  it 'does not silently reduce a bed below existing confirmed assignments' do
    room = house.rooms.create!(name: 'Assigned room')
    bed = room.beds.create!(size: :queen)
    request = bed.bed_requests.create!(user: manager, arrival: '2026-11-10', departure: '2026-11-12', spaces: 2)
    request.transition!('confirmed')
    patch users_lodging_room_bed_path(house, room, bed), params: { bed: { capacity: 1 } }
    expect(bed.reload.capacity).to eq(2)
  end

  it 'does not expose another guests visit by guessed ID' do
    other = create(:user)
    stay = season.guest_stays.create!(host: manager, guest: other, guest_name: 'Private',
      email: other.account.email, arrival: '2026-11-10', departure: '2026-11-12')
    sign_in person.account
    expect { get guest_visit_path(stay) }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'rejects invalid date and count requests without server errors' do
    post users_lodging_guest_stays_path(house), params: {
      guest_stay: { house_season_id: season.id, guest_name: 'Invalid', email: person.account.email,
                    arrival: 'bad-date', departure: '2026-11-12', cars: -1 }
    }
    expect(response).to have_http_status(:redirect)
    expect(season.guest_stays).to be_empty
  end

  it 'hides every house link on the landing page from an uninvited skier' do
    sign_in person.account
    get root_path
    expect(response.body).not_to include('My houses', users_lodgings_path)
  end
end
