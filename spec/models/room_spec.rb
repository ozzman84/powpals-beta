# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Room do
  describe 'relationships' do
    it { is_expected.to have_many(:beds) }
    it { is_expected.to belong_to(:lodging) }
    it { is_expected.to accept_nested_attributes_for(:beds) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end
end
