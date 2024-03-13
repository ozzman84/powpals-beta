# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resort, type: :model do
  it { should have_many(:account_ski_days).dependent(:destroy) }
  it { should have_many(:accounts).through(:account_ski_days) }
  it { should have_many(:season_pass_resorts).dependent(:destroy) }
  it { should have_many(:season_passes).through(:season_pass_resorts) }
  it { should have_many(:blackout_days).dependent(:destroy) }

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:city) }
    it { should validate_presence_of(:state) }

    it { should validate_uniqueness_of(:name).case_insensitive }
    it { should validate_length_of(:name).is_at_most(100) }
    it { should validate_length_of(:city).is_at_most(50) }
    it { should validate_length_of(:state).is_at_most(50) }
    it { should validate_numericality_of(:lat) }
    it { should validate_numericality_of(:long) }

    it { should allow_value(40.7128).for(:lat) }
    it { should allow_value(-74.0060).for(:long) }
  end

  describe '#skier_count_for_date' do
    let(:resort) { create(:resort) }
    let(:date) { Date.today }

    context 'when there are ski days for the specified date' do
      before do
        accounts = create_list(:account, 3)
        index = 0
        3.times do
          AccountSkiDay.create(account: accounts[index], resort:, start_date: date)
          index += 1
        end
      end

      it 'returns the count of ski days for the specified date' do
        expect(resort.skier_count_for_date(date)).to eq(3)
      end
    end

    context 'when there are no ski days for the specified date' do
      it 'returns zero' do
        expect(resort.skier_count_for_date(date)).to eq(0)
      end
    end
  end

  describe '#next_10_day_skier_count' do
    let(:resort) { create(:resort) }

    it 'returns skier counts for the next 10 days' do
      today = Date.today
      expected_counts = {
        today => 1,
        today + 1 => 1,
        today + 2 => 1,
        today + 3 => 1,
        today + 4 => 1,
        today + 5 => 1,
        today + 6 => 1,
        today + 7 => 1,
        today + 8 => 1
      }

      # Create ski days for the next 10 days
      (today..today + 10).each do |date|
        accounts = create_list(:account, 2)
        index = 0
        2.times do
          AccountSkiDay.create(account: accounts[0], resort:, start_date: date)
          index += 1
        end
        index = 0
      end

      expect(resort.next_10_day_skier_count).to eq(expected_counts)
    end
  end
end
