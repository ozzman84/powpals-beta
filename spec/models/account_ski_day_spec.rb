# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountSkiDay, type: :model do
  it { should belong_to(:resort) }
  it { should belong_to(:account) }
end
