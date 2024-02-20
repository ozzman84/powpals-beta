# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resort, type: :model do
  it { should have_many(:account_ski_days) }
  it { should have_many(:accounts).through(:account_ski_days) }
  it { should have_many(:season_pass_resorts) }
  it { should have_many(:season_passes).through(:season_pass_resorts) }
  it { should have_many(:blackout_days) }

  describe 'Resort List with 10 day totals' do
    let(:user) { create(:user) }
    let(:user2) { create(:user) }
    let(:account) { create(:account) }
    let(:account2) { create(:account) }
    let(:resort) { create_list(:resort) }
    let(:resort2) { create_list(:resort) }

    it 'should list users' do
      user.account.account_ski_days.create(:account_ski_day, resort_id: resort.id)
      binding.pry
    end
  end
end
