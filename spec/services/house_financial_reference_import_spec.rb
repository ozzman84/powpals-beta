# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HouseFinancialReferenceImport do
  let(:house) { create(:lodging) }
  let(:season) do
    house.house_seasons.create!(name: 'Historical reference', starts_on: '2023-11-01', ends_on: '2024-04-30',
      policy_status: :reference)
  end

  let(:rows) do
    [
      { 'kind' => 'guest_fee', 'description' => 'Reported guest fee', 'month_on' => '2023-11-01',
        'amount_cents' => 15_000, 'received' => true },
      { 'kind' => 'expense', 'description' => 'Source expense pending reimbursement', 'month_on' => '2023-11-01',
        'amount_cents' => 34_000, 'received' => false }
    ]
  end

  it 'preserves reported receipts and pending expenses without inventing users or receipt dates' do
    2.times { described_class.new(season, source_key: 'historical').call(rows) }
    expect(HouseLedgerEntry.count).to eq(2)
    expect(HousePayment.count).to eq(1)
    expect(HousePayment.first.paid_on).to be_nil
    expect(HousePayment.first.source_reported?).to be(true)
    expect(Account.count).to eq(0)
    totals = season.monthly_summary(Date.new(2023, 11, 1))
    expect(totals[:received] - totals[:expenses]).to eq(-19_000)
  end

  it 'refuses to modify an already imported financial row' do
    described_class.new(season, source_key: 'historical').call(rows)
    rows.first['amount_cents'] = 20_000
    expect do
      described_class.new(season, source_key: 'historical').call(rows)
    end.to raise_error(ArgumentError, /source row changed/)
    expect(HouseLedgerEntry.guest_fee.first.amount_cents).to eq(15_000)
  end

  it 'does not apply historical transactions to a current draft season' do
    season.update!(policy_status: :draft)
    expect do
      described_class.new(season, source_key: 'historical').call(rows)
    end.to raise_error(ArgumentError, /historical reference/)
    expect(HouseLedgerEntry.count).to eq(0)
  end
end
