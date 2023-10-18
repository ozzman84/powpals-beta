# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LodgingCalendar, type: :model do
  it { should belong_to(:user) }
  it { should belong_to(:bed) }
  it { should belong_to(:lodging) }
end
