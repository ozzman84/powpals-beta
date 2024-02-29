# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SeasonPass, type: :model do
  it { should have_many(:account_season_passes).dependent(:destroy) }
  it { should have_many(:accounts).through(:account_season_passes) }
  it { should have_many(:season_pass_resorts).dependent(:destroy) }
  it { should have_many(:resorts).through(:season_pass_resorts) }
  it { should have_many(:blackout_days).dependent(:destroy) }
  it { should have_many(:blackout_resorts).through(:blackout_days) }

  describe 'validations' do
    before { create(:season_pass) }
    it { should validate_uniqueness_of(:name).case_insensitive }
    it { should validate_presence_of(:name) }
  end
end
