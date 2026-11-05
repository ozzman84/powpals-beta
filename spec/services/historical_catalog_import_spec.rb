# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HistoricalCatalogImport do
  let(:user) { create(:user) }
  let(:snapshot) do
    { 'resorts' => [{ 'id' => 90, 'name' => 'Demo Mountain', 'city' => 'Frisco', 'state' => 'CO',
                      'lat' => '39.5', 'long' => '-106.1' }],
      'season_passes' => [{ 'id' => 80, 'name' => 'Demo Pass' }],
      'accounts' => [user.account.attributes.slice('id', 'email', 'provider', 'uid')],
      'season_pass_resorts' => Array.new(2) { { 'season_pass_id' => 80, 'resort_id' => 90 } },
      'account_season_passes' => [{ 'account_id' => user.account.id, 'season_pass_id' => 80 }],
      'account_ski_days' => [{ 'account_id' => user.account.id, 'resort_id' => 90, 'start_date' => '2024-03-09',
                               'status' => nil }] }
  end

  it 'restores catalog identities and related plans repeatably without creating accounts' do
    source = snapshot.deep_dup
    2.times { described_class.new.call(snapshot) }
    expect(Resort.count).to eq(1)
    expect(SeasonPass.count).to eq(1)
    expect(SeasonPassResort.count).to eq(1)
    expect(user.account.season_passes.pluck(:name)).to eq(['Demo Pass'])
    expect(user.account.account_ski_days.first.start_date).to eq(Date.new(2024, 3, 9))
    expect(Account.count).to eq(1)
    expect(snapshot).to eq(source)
  end

  it 'does not assign relationships to an account whose source identity differs' do
    snapshot['accounts'].first['uid'] = 'other-identity'
    described_class.new.call(snapshot)
    expect(AccountSeasonPass.count).to eq(0)
    expect(AccountSkiDay.count).to eq(0)
  end
end
