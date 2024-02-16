# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resort, type: :model do
  it { should have_many(:account_ski_days) }
  it { should have_many(:accounts).through(:account_ski_days) }
  it { should have_many(:season_pass_resorts) }
  it { should have_many(:season_passes).through(:season_pass_resorts) }
  it { should have_many(:blackout_days) }
end
