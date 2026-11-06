# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountSeasonPass do
  it { is_expected.to belong_to :account }
  it { is_expected.to belong_to :season_pass }
end
