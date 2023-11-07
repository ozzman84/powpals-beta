# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Lodging, type: :model do
  describe 'relationships' do
    it { should have_many(:roommates) }
    it { should have_many(:users).through(:roommates) }
    it { should have_many(:rooms) }
    it { should have_many(:calendars).dependent(:destroy) }
  end
end
