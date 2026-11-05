# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Guest charges and shared responsibility' do
  include Devise::Test::IntegrationHelpers

  let(:host) { create(:user) }
  let(:guest) { create(:user) }
  let(:accountant) { create(:user) }
  let(:house) { create(:lodging) }
  let(:season) do
    house.house_seasons.create!(name: 'Winter', starts_on: '2026-11-01', ends_on: '2027-04-30',
      policy_status: :confirmed, guest_rates: Date::DAYNAMES.index_with { 5000 }, free_nights: 5)
  end

  let(:stay) do
    season.guest_stays.create!(host: host, guest_name: 'Guest One', email: guest.account.email,
      arrival: '2026-11-30', departure: '2026-12-02', status: :approved)
  end

  before do
    create(:roommate, user: host, lodging: house)
    create(:roommate, user: accountant, lodging: house, role: :accountant)
  end

  it 'posts all occupied nights once, splits months and preserves the charged rates' do
    service = GuestStayBilling.new(stay, accountant.account)
    expect(service.post!.sum(&:amount_cents)).to eq(10_000)
    expect(stay.house_ledger_entries.pluck(:month_on)).to contain_exactly(Date.new(2026, 11, 1), Date.new(2026, 12, 1))
    season.update!(guest_rates: Date::DAYNAMES.index_with { 9000 })
    expect(service.post!.sum(&:amount_cents)).to eq(10_000)
    expect(stay.house_ledger_entries.count).to eq(2)
    expect(stay.house_ledger_entries.first.source_data['rates'].values).to all(eq(5000))
  end

  it 'lets guest or host payments reduce one balance, while keeping other members payments private' do
    stay.accept!(guest.account)
    entry = GuestStayBilling.new(stay, accountant.account).post!.first
    entry.record_payment!(amount_cents: 2000, paid_on: '2026-12-02', recorded_by: accountant.account, paid_by: guest)
    entry.record_payment!(amount_cents: 1000, paid_on: '2026-12-02', recorded_by: accountant.account, paid_by: host)
    expect(entry.outstanding_cents).to eq(2000)
    expect(entry.house_payments.count).to eq(2)
    sign_in guest.account
    get guest_visit_path(stay)
    expect(response.body).to include('Outstanding: $20.00')
    expect(response.body).not_to include('Record payment', 'House accounting')
    sign_in host.account
    get users_lodging_my_payments_path(house, season_id: season.id)
    expect(response.body).to include('Guest One', 'Outstanding: $20.00')
    expect do
      entry.record_payment!(amount_cents: 1, paid_on: '2026-12-02', recorded_by: accountant.account,
        paid_by: accountant)
    end.to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'voids unpaid charges and bed requests on cancellation but preserves paid stays pending refund reconciliation' do
    GuestStayBilling.new(stay, accountant.account).post!
    stay.transition!('cancelled')
    expect(stay.house_ledger_entries.map(&:outstanding_cents)).to all(eq(0))
    expect(stay.house_ledger_entries.map(&:voided_at)).to all(be_present)
    expect(season.monthly_summary(Date.new(2026, 11, 1))[:fees]).to eq(0)
    expect { stay.transition!('approved') }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'blocks cancellation that would erase receipts and disallows host self-posting charges' do
    expect { GuestStayBilling.new(stay, host.account).post! }.to raise_error(Pundit::NotAuthorizedError)
    entry = GuestStayBilling.new(stay, accountant.account).post!.first
    entry.record_payment!(amount_cents: 100, paid_on: '2026-12-02', recorded_by: accountant.account)
    expect { stay.transition!('cancelled') }.to raise_error(ActiveRecord::RecordInvalid, /reconcile refunds/)
    expect(stay.reload).to be_approved
    expect(entry.reload.voided_at).to be_nil
  end

  it 'rejects unconfirmed rates and unlinked manual guest charges against a roommate' do
    season.update!(policy_status: :draft)
    expect { GuestStayBilling.new(stay, accountant.account).post! }.to raise_error(ArgumentError, /not been confirmed/)
    expect(stay.house_ledger_entries).to be_empty
    sign_in accountant.account
    post users_lodging_house_season_house_ledger_entries_path(house, season), params: {
      house_ledger_entry: { kind: 'guest_fee', user_id: host.id, description: 'Roommate own stay',
                            month_on: '2026-11-01', amount: '50' }
    }
    expect(season.house_ledger_entries).to be_empty
  end
end
