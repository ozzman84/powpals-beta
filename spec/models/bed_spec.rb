# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Bed do
  describe 'relationships' do
    it { is_expected.to belong_to(:room) }
  end
end
