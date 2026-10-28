# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Season guest fees and house rules' do
  include Devise::Test::IntegrationHelpers

  let(:user) { create(:user) }
  let(:house) { create(:lodging) }
  let!(:membership) { create(:roommate, user: user, lodging: house) }
  let(:season) { house.house_seasons.create!(name: 'Winter', starts_on: '2026-11-01', ends_on: '2027-04-30') }

  before do
    sign_in user.account
  end

  it 'shows a season to members without enabling draft guest fees' do
    get users_lodging_house_season_path(house, season)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('not confirmed for charging guests')
    expect(response.body).not_to include('Add ledger entry')
  end

  it 'forbids ordinary members from changing policy or recording financial entries' do
    patch users_lodging_house_season_path(house, season), params: { house_season: { rules: 'Changed' } }
    expect(response).to have_http_status(:forbidden)
    post users_lodging_house_season_house_ledger_entries_path(house, season), params: {
      house_ledger_entry: { kind: 'guest_fee', description: 'Unauthorized', month_on: '2026-11-01', amount: '50' }
    }
    expect(response).to have_http_status(:forbidden)
    expect(HouseLedgerEntry.count).to eq(0)
  end

  it 'scopes season IDs to the selected house' do
    membership.update!(role: :lease_holder)
    other = create(:lodging)
    other_season = other.house_seasons.create!(name: 'Private', starts_on: '2026-11-01', ends_on: '2027-04-30')
    expect { get users_lodging_house_season_path(house, other_season) }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'scopes payment entry IDs to the selected season' do
    membership.update!(role: :lease_holder)
    other = create(:lodging)
    other_season = other.house_seasons.create!(name: 'Private', starts_on: '2026-11-01', ends_on: '2027-04-30')
    entry = other_season.house_ledger_entries.create!(kind: :guest_fee, description: 'Private fee',
      amount_cents: 5000, month_on: '2026-11-01')
    expect do
      post users_lodging_house_season_house_ledger_entry_house_payments_path(house, season, entry),
        params: { house_payment: { amount: '50', paid_on: '2026-11-10' } }
    end.to raise_error(ActiveRecord::RecordNotFound)
    expect(HousePayment.count).to eq(0)
  end

  it 'keeps financial history private from guest memberships' do
    membership.update!(role: :guest)
    get users_lodging_house_season_path(house, season)
    expect(response).to have_http_status(:forbidden)
  end

  it 'lets managers record an expense and partial reimbursement with an audit identity' do
    membership.update!(role: :lease_holder)
    post users_lodging_house_season_house_ledger_entries_path(house, season), params: {
      house_ledger_entry: { kind: 'expense', description: 'Cleaning supplies', month_on: '2026-11-01', amount: '34.50' }
    }
    entry = season.house_ledger_entries.last
    expect(entry.amount_cents).to eq(3450)
    post users_lodging_house_season_house_ledger_entry_house_payments_path(house, season, entry), params: {
      house_payment: { amount: '10', paid_on: '2026-11-15', reference: 'External receipt', source_reported: true }
    }
    payment = entry.house_payments.last
    expect(payment.recorded_by).to eq(user.account)
    expect(payment.source_reported?).to be(false)
    expect(entry.outstanding_cents).to eq(2450)
  end
end
