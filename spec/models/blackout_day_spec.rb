# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BlackoutDay do
  it { is_expected.to belong_to(:resort) }
  it { is_expected.to belong_to(:season_pass) }
end
