# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resort, type: :model do
  it { should have_many(:account_ski_days) }
  it { should have_many(:accounts).through(:account_ski_days) }
  it { should have_many(:season_pass_resorts) }
  it { should have_many(:season_passes).through(:season_pass_resorts) }
  it { should have_many(:blackout_days) }

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:city) }
    it { should validate_presence_of(:state) }

    it { should validate_uniqueness_of(:name).case_insensitive }
    it { should validate_length_of(:name).is_at_most(100) }
    it { should validate_length_of(:city).is_at_most(50) }
    it { should validate_length_of(:state).is_at_most(50) }
  end

  describe 'Resort List with 10 day totals' do
    let(:user) { create(:user) }
    let(:user2) { create(:user) }
    let(:account) { create(:account) }
    let(:account2) { create(:account) }
    let(:resort) { create_list(:resort) }
    let(:resort2) { create_list(:resort) }

    #   it 'should list users' do
    #     # user.account.account_ski_days.create(:account_ski_day, resort_id: resort.id)
    #   end
  end
end
