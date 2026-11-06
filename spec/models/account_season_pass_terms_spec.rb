# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountSeasonPass do
  include ActiveSupport::Testing::TimeHelpers

  let(:account) { create(:account) }
  let(:pass) { create(:season_pass) }

  it 'expires after the final valid date while preserving the owned record' do
    owned = create(:account_season_pass, account: account, season_pass: pass,
      starts_on: Date.current - 30, expires_on: Date.current)
    expect(owned).to be_current
    expect(account).to be_any_season_passes
    travel_to(1.day.from_now) do
      expect(owned).not_to be_current
      expect(account).not_to be_any_season_passes
      expect(owned.status_label).to eq('Expired')
      expect(account.account_season_passes.count).to eq(1)
    end
  end

  it 'supports a new nonoverlapping season for the same type without deleting history' do
    create(:account_season_pass, account: account, season_pass: pass,
      starts_on: Date.current - 365, expires_on: Date.current - 1, season_label: 'Previous')
    renewed = create(:account_season_pass, account: account, season_pass: pass,
      starts_on: Date.current, expires_on: Date.current + 180, season_label: 'Current')
    expect(renewed).to be_current
    expect(account.account_season_passes.count).to eq(2)
  end

  it 'rejects overlapping owned terms and missing dates' do
    create(:account_season_pass, account: account, season_pass: pass)
    overlap = build(:account_season_pass, account: account, season_pass: pass, starts_on: Date.current)
    expect(overlap).not_to be_valid
    missing = build(:account_season_pass, starts_on: nil, expires_on: nil)
    expect(missing).not_to be_valid
  end

  it 'keeps imported unknown seasons inactive instead of assuming a renewal' do
    owned = create(:account_season_pass, account: account, season_pass: pass,
      starts_on: nil, expires_on: nil, season_label: nil, season_unknown: true)
    expect(owned).not_to be_current
    expect(account).not_to be_any_season_passes
    expect(owned.status_label).to include('unknown')
  end

  it 'does not treat an upcoming pass as current access' do
    owned = create(:account_season_pass, account: account, season_pass: pass,
      starts_on: Date.current + 10, expires_on: Date.current + 180)
    expect(owned.status_label).to eq('Upcoming')
    expect(account.active_season_passes).to be_empty
  end
end
