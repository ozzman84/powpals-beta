# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SeasonPassResort, type: :model do
  it { should belong_to(:season_pass) }
  it { should belong_to(:resort) }
end
