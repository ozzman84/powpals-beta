# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account, type: :model do
  describe 'references' do
    it { should have_one(:user) }
    it { should have_many :account_season_passes }
    it { should have_many(:season_passes).through(:account_season_passes) }
    it { should have_many :account_ski_days }
    it { should have_many(:ski_day_resorts).through(:account_ski_days) }
  end

  describe '#order_resorts_by_ski_days' do
    it 'orders resorts by ski days for the next n days' do
      account = create(:account)
      resort1 = create(:resort)
      resort2 = create(:resort, name: 'Breck')
      create(:season_pass, resorts: [resort1])
      create(:season_pass, resorts: [resort2])
      create(:account_ski_day, account:, resort: resort1, start_date: Date.today)
      create(:account_ski_day, account:, resort: resort1, start_date: Date.today + 1)
      create(:account_ski_day, account:, resort: resort1, start_date: Date.today + 2)
      create(:account_ski_day, account:, resort: resort2, start_date: Date.today)
      create(:account_ski_day, account:, resort: resort2, start_date: Date.today + 1)

      ordered_resorts = account.order_resorts_by_ski_days(2)

      expect(ordered_resorts).to eq([resort1, resort2])
    end
  end

  describe '#resort_data_for_next_10_days' do
    it 'returns resort data for the next 10 days' do
      account = create(:account)
      resort1 = create(:resort, name: 'Resort A')
      resort2 = create(:resort, name: 'Resort B')
      create(:season_pass, resorts: [resort1])
      create(:season_pass, name: 'Epic Pass', resorts: [resort2])
      create(:account_ski_day, account:, resort: resort1, start_date: Date.today)
      create(:account_ski_day, account:, resort: resort1, start_date: Date.today + 1)
      create(:account_ski_day, account:, resort: resort1, start_date: Date.today + 2)
      create(:account_ski_day, account:, resort: resort2, start_date: Date.today)
      create(:account_ski_day, account:, resort: resort2, start_date: Date.today + 1)

      resort_data = account.resort_data_for_multiple_days

      expect(resort_data.keys).to match_array(['Resort A', 'Resort B'])
      expect(resort_data['Resort A'][:next_10_day_skier_count].size).to eq(9)
      expect(resort_data['Resort A'][:next_10_day_skier_count].size).to eq(9)
    end
  end
end
