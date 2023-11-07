# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'relationships' do
    it { should have_many(:roommates) }
    it { should have_many(:lodgings).through(:roommates) }
    it { should belong_to(:account) }
    it { should have_many(:calendars).dependent(:destroy) }
  end
end
