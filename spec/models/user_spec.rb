# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'relationships' do
    it { should have_many(:roommates) }
    it { should have_many(:lodgings).through(:roommates) }
  end
end
