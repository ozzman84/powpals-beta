require 'rails_helper'

RSpec.describe SeasonPass, type: :model do
  it { should have_many :user_season_passes }
  it { should have_many(:users).through(:user_season_passes) }
end
