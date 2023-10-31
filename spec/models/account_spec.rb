# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account, type: :model do
  describe 'references' do
    it { should have_one(:user) }
  end
end
