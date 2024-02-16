# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SeasonPass, type: :model do
  it { should have_many :account_season_passes }
  it { should have_many(:accounts).through(:account_season_passes) }
  it { should have_many :season_pass_resorts }
  it { should have_many(:resorts).through(:season_pass_resorts) }
  it { should have_many :blackout_days }
  it { should have_many(:blackout_resorts).through(:blackout_days) }
end
