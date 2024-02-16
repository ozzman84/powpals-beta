# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BlackoutDay, type: :model do
  it { should belong_to(:resort) }
  it { should belong_to(:season_pass) }
end
