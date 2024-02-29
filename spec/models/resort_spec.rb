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
  end

  # describe 'Resort List with 10 day totals' do
  #   let(:user) { create(:user) }
  #   let(:user2) { create(:user) }
  #   let(:account) { create(:account) }
  #   let(:account2) { create(:account) }
  #   let(:resort) { create_list(:resort) }
  #   let(:resort2) { create_list(:resort) }

  #   #   it 'should list users' do
  #   #     # user.account.account_ski_days.create(:account_ski_day, resort_id: resort.id)
  #   #   end
  # end

  describe '#skier_count_for_date' do
    let(:resort) { create(:resort) }
    let(:date) { Date.today }

    context 'when there are ski days for the specified date' do
      before do
        account = create(:account)

        3.times do
          AccountSkiDay.create(account:, resort:, start_date: date)
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
      expected_counts = {
        Date.new(2024, 2, 29) => 5,
        Date.new(2024, 3, 1) => 5,
        Date.new(2024, 3, 2) => 5,
        Date.new(2024, 3, 3) => 5,
        Date.new(2024, 3, 4) => 5,
        Date.new(2024, 3, 5) => 5,
        Date.new(2024, 3, 6) => 5,
        Date.new(2024, 3, 7) => 5,
        Date.new(2024, 3, 8) => 5,
        Date.new(2024, 3, 9) => 5
      }

      # Create ski days for the next 10 days
      (Date.today..9.days.from_now).each do |date|
        account = create(:account)

        5.times do
          AccountSkiDay.create(account:, resort:, start_date: date)
        end
      end

      expect(resort.next_10_day_skier_count).to eq(expected_counts)
    end
  end
end
