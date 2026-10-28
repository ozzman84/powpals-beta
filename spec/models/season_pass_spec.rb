# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SeasonPass do
  it { is_expected.to have_many(:account_season_passes).dependent(:destroy) }
  it { is_expected.to have_many(:accounts).through(:account_season_passes) }
  it { is_expected.to have_many(:season_pass_resorts).dependent(:destroy) }
  it { is_expected.to have_many(:resorts).through(:season_pass_resorts) }
  it { is_expected.to have_many(:blackout_days).dependent(:destroy) }
  it { is_expected.to have_many(:blackout_resorts).through(:blackout_days) }

  describe 'validations' do
    before do
      create(:season_pass)
    end

    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
    it { is_expected.to validate_presence_of(:name) }
  end
end
