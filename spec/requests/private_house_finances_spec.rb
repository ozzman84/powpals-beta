# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Private house finances' do
  include Devise::Test::IntegrationHelpers

  let(:house) { create(:lodging) }
  let(:member) { create(:user, full_name: 'Member One') }
  let(:other) { create(:user, full_name: 'Member Two') }
  let(:accountant) { create(:user, full_name: 'House Accountant') }
  let!(:membership) { create(:roommate, lodging: house, user: member) }
  let(:season) do
    house.house_seasons.create!(name: 'Winter', starts_on: '2026-11-01', ends_on: '2027-04-30',
      monthly_rent_cents: 888_888, source_notes: 'PRIVATE ACCOUNTING SOURCE')
  end

  let!(:mine) do
    membership
    season.house_ledger_entries.create!(user: member, kind: :guest_fee, description: 'My guest fees',
      month_on: '2026-11-01', amount_cents: 5000)
  end

  let!(:theirs) do
    create(:roommate, lodging: house, user: other)
    season.house_ledger_entries.create!(user: other, kind: :guest_fee, description: 'Other member private charge',
      month_on: '2026-11-01', amount_cents: 9900)
  end

  before do
    create(:roommate, lodging: house, user: accountant, role: :accountant)
    season.house_ledger_entries.create!(kind: :expense, description: 'Private shared expense',
      month_on: '2026-11-01', amount_cents: 1234)

    sign_in member.account
  end

  it 'reserves the full accounting view for the designated accountant, including against house managers' do
    %i[roommate admin lease_holder rent_collector guest].each do |role|
      membership.update!(role: role)
      get users_lodging_house_season_finance_path(house, season)
      expect(response).to have_http_status(:forbidden)
    end
    sign_in accountant.account
    get users_lodging_house_season_finance_path(house, season)
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Private shared expense', 'Other member private charge',
      'PRIVATE ACCOUNTING SOURCE')
  end

  it 'does not leak the books or budget into general season pages' do
    get users_lodging_house_season_path(house, season)
    expect(response).to have_http_status(:ok)
    expect(response.body).not_to include('Other member private charge', 'Private shared expense',
      'PRIVATE ACCOUNTING SOURCE', '8,888.88')
  end

  it 'shows only the signed-in member entries even if another user ID is supplied' do
    get users_lodging_my_payments_path(house, season_id: season.id, user_id: other.id)
    expect(response.body).to include('My guest fees')
    expect(response.body).not_to include('Other member private charge', 'Private shared expense', 'Record payment')
    post users_lodging_house_season_house_ledger_entry_house_payments_path(house, season, mine),
      params: { house_payment: { amount: '50', paid_on: '2026-11-05' } }
    expect(response).to have_http_status(:forbidden)
    expect(mine.house_payments.count).to eq(0)
  end

  it 'limits the collector to rent and deposits without access to accounting or guest fees' do
    membership.update!(role: :rent_collector)
    rent = season.house_ledger_entries.create!(user: other, kind: :rent, description: 'November rent',
      month_on: '2026-11-01', amount_cents: 10_000)
    get users_lodging_house_season_rent_collection_path(house, season)
    expect(response.body).to include('November rent')
    expect(response.body).not_to include('My guest fees', 'Other member private charge', 'Private shared expense')
    post users_lodging_house_season_house_ledger_entry_house_payments_path(house, season, rent),
      params: { house_payment: { amount: '40', paid_on: '2026-11-05' } }
    expect(rent.reload.outstanding_cents).to eq(6000)
    expect do
      post users_lodging_house_season_house_ledger_entry_house_payments_path(house, season, theirs),
        params: { house_payment: { amount: '10', paid_on: '2026-11-05' } }
    end.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'rejects forged collector expense creation and budget changes' do
    membership.update!(role: :rent_collector)
    post users_lodging_house_season_house_ledger_entries_path(house, season), params: {
      house_ledger_entry: { kind: 'expense', description: 'Not allowed', month_on: '2026-11-01', amount: '10' }
    }
    expect(response).to have_http_status(:forbidden)
    patch users_lodging_house_season_finance_path(house, season), params: { budget: { monthly_rent: '1' } }
    expect(response).to have_http_status(:forbidden)
    expect(season.reload.monthly_rent_cents).to eq(888_888)
  end

  it 'does not allow an accountant to assign a charge to someone outside this house' do
    outsider = create(:user)
    sign_in accountant.account
    expect do
      post users_lodging_house_season_house_ledger_entries_path(house, season), params: {
        house_ledger_entry: { kind: 'guest_fee', user_id: outsider.id, description: 'Wrong house',
                              month_on: '2026-11-01', amount: '10' }
      }
    end.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'does not guess ownership for historical unassigned entries' do
    season.house_ledger_entries.create!(kind: :guest_fee, description: 'Unassigned historical fee',
      month_on: '2026-11-01', amount_cents: 5000, source_key: 'legacy-row')
    get users_lodging_my_payments_path(house, season_id: season.id)
    expect(response.body).not_to include('Unassigned historical fee')
  end

  it 'permits only one designated accountant per house' do
    duplicate = build(:roommate, lodging: house, user: create(:user), role: :accountant)
    expect(duplicate).not_to be_valid
  end
end
