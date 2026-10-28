# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HouseSeason do
  let(:house) { create(:lodging) }
  let(:season) do
    house.house_seasons.create!(name: 'Winter', starts_on: '2026-11-01', ends_on: '2027-04-30')
  end

  it 'requires all rates before activating a policy' do
    expect(season.update(policy_status: :confirmed)).to be(false)
    expect(season.errors[:guest_rates]).not_to be_empty
    expect(season.update(policy_status: :confirmed, guest_rates: Date::DAYNAMES.index_with { 3000 })).to be(true)
  end

  it 'keeps money in integer cents and rejects invalid money input' do
    expect(HouseMoney.cents('572.73')).to eq(57_273)
    expect { HouseMoney.cents('30.001') }.to raise_error(ArgumentError)
    expect { HouseMoney.cents('-30') }.to raise_error(ArgumentError)
  end

  it 'does not calculate charges from draft or historical rates' do
    expect do
      GuestFeeQuote.new(season).call(arrival: '2026-11-05', departure: '2026-11-08', guests: 2)
    end.to raise_error(ArgumentError, /not been confirmed/)
  end

  it 'quotes occupied nights with Thursday as a weekend rate and excludes checkout' do
    rates = Date::DAYNAMES.index_with { |day| %w[Monday Tuesday Wednesday].include?(day) ? 3000 : 5000 }
    season.update!(policy_status: :confirmed, guest_rates: rates)
    quote = GuestFeeQuote.new(season)
    expect(quote.call(arrival: '2026-11-04', departure: '2026-11-07', guests: 2)).to eq(26_000)
    expect do
      quote.call(arrival: '2026-10-31', departure: '2026-11-02', guests: 1)
    end.to raise_error(ArgumentError, /within the rental season/)
  end

  it 'requires a dog-fee basis and handles configured free nights' do
    season.update!(policy_status: :confirmed, guest_rates: Date::DAYNAMES.index_with { 5000 },
      free_nights: 1, dog_fee_cents: 2500)
    quote = GuestFeeQuote.new(season)
    expect do
      quote.call(arrival: '2026-11-05', departure: '2026-11-08', guests: 1, dogs: 1)
    end.to raise_error(ArgumentError, /dog fee/)
    season.update!(dog_fee_basis: :per_stay)
    expect(quote.call(arrival: '2026-11-05', departure: '2026-11-08', guests: 1, dogs: 1)).to eq(12_500)
  end

  it 'supports partial receipts without allowing overpayment' do
    user = create(:user)
    entry = season.house_ledger_entries.create!(kind: :guest_fee, description: 'Weekend guest',
      month_on: '2026-11-01', amount_cents: 10_000)
    entry.record_payment!(amount_cents: 4000, paid_on: '2026-11-10', recorded_by: user.account)
    expect(entry.outstanding_cents).to eq(6000)
    expect do
      entry.record_payment!(amount_cents: 6001, paid_on: '2026-11-10', recorded_by: user.account)
    end.to raise_error(ActiveRecord::RecordInvalid)
    entry.record_payment!(amount_cents: 6000, paid_on: '2026-11-10', recorded_by: user.account)
    expect(entry.outstanding_cents).to eq(0)
  end

  it 'separates source-reported receipts, incurred expenses and reimbursements' do
    fee = season.house_ledger_entries.create!(kind: :guest_fee, description: 'Source fee',
      month_on: '2026-11-01', amount_cents: 15_000)
    fee.record_payment!(amount_cents: 15_000, source_reported: true)
    season.house_ledger_entries.create!(kind: :expense, description: 'Supplies awaiting reimbursement',
      month_on: '2026-11-01', amount_cents: 34_000)
    totals = season.monthly_summary(Date.new(2026, 11, 1))
    expect(totals).to include(received: 15_000, expenses: 34_000, reimbursed: 0, outstanding: 0)
    expect(fee.house_payments.first.paid_on).to be_nil
  end

  it 'refuses accounting months outside the season' do
    entry = season.house_ledger_entries.new(kind: :expense, description: 'Other year',
      month_on: '2025-11-01', amount_cents: 100)
    expect(entry).not_to be_valid
  end
end
