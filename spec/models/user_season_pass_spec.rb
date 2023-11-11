require 'rails_helper'

RSpec.describe UserSeasonPass, type: :model do
  it { should belong_to :user }
  it { should belong_to :season_pass }
end
