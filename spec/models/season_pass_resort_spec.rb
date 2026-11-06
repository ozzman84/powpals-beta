# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SeasonPassResort do
  it { is_expected.to belong_to(:season_pass) }
  it { is_expected.to belong_to(:resort) }
end
