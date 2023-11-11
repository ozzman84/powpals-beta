require 'rails_helper'

RSpec.describe AccountSeasonPass, type: :model do
  it { should belong_to :account }
  it { should belong_to :season_pass }
end
