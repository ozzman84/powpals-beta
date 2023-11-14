# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Roommate, type: :model do
  describe 'relationships' do
    it { should belong_to(:user) }
    it { should belong_to(:lodging) }
  end

  describe 'validations' do
    let(:account) { create(:account) }
    let(:user) { create(:user) }
    let(:lodging) { create(:lodging) }
    let!(:roommate) { Roommate.create(role: 'roommate', user_id: user.id, lodging_id: lodging.id) }

    it { should validate_uniqueness_of(:user_id).scoped_to(:lodging_id).with_message(/This person is already a roommate/) }
  end
end
