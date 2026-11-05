# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account do
  let(:account) { create(:account) }
  let(:first_pass) { create(:season_pass) }
  let(:second_pass) { create(:season_pass) }
  let(:quiet) { create(:resort, name: 'Quiet Mountain') }
  let(:popular) { create(:resort, name: 'Popular Mountain') }

  before do
    [first_pass, second_pass].each { |pass| create(:account_season_pass, account: account, season_pass: pass) }
    [quiet, popular].each { |resort| SeasonPassResort.create!(season_pass: first_pass, resort: resort) }
    SeasonPassResort.create!(season_pass: second_pass, resort: quiet)
  end

  it 'ranks populated ski plans without eager-load grouping errors or duplicate pass resorts' do
    create(:account_ski_day, account: account, resort: popular, start_date: Date.current)
    create(:account_ski_day, account: create(:account), resort: popular, start_date: Date.current)
    create(:account_ski_day, account: account, resort: quiet, start_date: Date.current)
    data = account.resort_data_for_multiple_days
    expect(data.keys).to eq(['Popular Mountain', 'Quiet Mountain'])
    expect(data['Popular Mountain'][:next_10_day_skier_count].first).to eq(2)
    expect(data['Quiet Mountain'][:next_10_day_skier_count].first).to eq(1)
  end

  it 'retains eligible resorts without plans and excludes day eleven from ten-day ranking' do
    outside = create(:resort)
    create(:account_ski_day, account: account, resort: quiet, start_date: Date.current + 10)
    create(:account_ski_day, account: account, resort: outside, start_date: Date.current)
    data = account.resort_data_for_multiple_days
    expect(data.keys).to eq(['Popular Mountain', 'Quiet Mountain'])
    expect(data.values.map { |row| row[:next_10_day_skier_count].sum }).to eq([0, 0])
  end
end
