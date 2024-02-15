# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account, type: :model do
  describe 'references' do
    it { should have_one(:user) }
    it { should have_many :account_season_passes }
    it { should have_many(:season_passes).through(:account_season_passes) }
    it { should have_many :account_ski_days }
    it { should have_many(:resorts).through(:account_ski_days) }
  end
end
