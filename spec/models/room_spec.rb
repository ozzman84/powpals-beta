# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Room, type: :model do
  describe 'relationships' do
    it { should have_many(:beds) }
    it { should belong_to(:lodging) }
    it { should accept_nested_attributes_for(:beds) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end
end
