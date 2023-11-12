# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SeasonPass, type: :model do
  it { should have_many :account_season_passes }
  it { should have_many(:accounts).through(:account_season_passes) }
end
