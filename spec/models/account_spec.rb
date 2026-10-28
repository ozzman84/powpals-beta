# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account do
  describe 'references' do
    it { is_expected.to have_one(:user) }
    it { is_expected.to have_many :account_season_passes }
    it { is_expected.to have_many(:season_passes).through(:account_season_passes) }
    it { is_expected.to have_many :account_ski_days }
    it { is_expected.to have_many(:ski_day_resorts).through(:account_ski_days) }
  end

  describe '#order_resorts_by_ski_days' do
    it 'orders resorts by ski days for the next n days' do
      account = create(:account)
      resort1 = create(:resort)
      resort2 = create(:resort, name: 'Breck')
      create(:season_pass, resorts: [resort1])
      create(:season_pass, name: 'Epic Pass', resorts: [resort2])
      create(:account_ski_day, account: account, resort: resort1, start_date: Date.current)
      create(:account_ski_day, account: account, resort: resort1, start_date: Date.current + 1)
      create(:account_ski_day, account: account, resort: resort1, start_date: Date.current + 2)
      create(:account_ski_day, account: account, resort: resort2, start_date: Date.current)
      create(:account_ski_day, account: account, resort: resort2, start_date: Date.current + 1)

      ordered_resorts = account.resort_data_for_multiple_days(2)

      expect(ordered_resorts).to eq({ resort2.name => { next_10_day_skier_count: [1, 1, 0, 0, 0, 0, 0, 0, 0, 0] },
                                      resort1.name => { next_10_day_skier_count: [1, 1, 1, 0, 0, 0, 0, 0, 0, 0] } })
    end
  end

  describe '#resort_data_for_next_10_days' do
    it 'returns resort data for the next 10 days' do
      account = create(:account)
      resort1 = create(:resort, name: 'Resort A')
      resort2 = create(:resort, name: 'Resort B')
      create(:season_pass, resorts: [resort1])
      create(:season_pass, name: 'Epic Pass', resorts: [resort2])
      create(:account_ski_day, account: account, resort: resort1, start_date: Date.current)
      create(:account_ski_day, account: account, resort: resort1, start_date: Date.current + 1)
      create(:account_ski_day, account: account, resort: resort1, start_date: Date.current + 2)
      create(:account_ski_day, account: account, resort: resort2, start_date: Date.current)
      create(:account_ski_day, account: account, resort: resort2, start_date: Date.current + 1)

      resort_data = account.resort_data_for_multiple_days

      expect(resort_data.keys).to match_array(['Resort A', 'Resort B'])
      expect(resort_data['Resort A'][:next_10_day_skier_count].size).to eq(10)
      expect(resort_data['Resort A'][:next_10_day_skier_count].size).to eq(10)
    end
  end
end
