# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Calendar do
  describe 'Relationships' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:lodging) }
  end

  describe 'Validations' do
    let(:user) { create(:user, account_id: create(:account).id) }
    let(:lodging) { create(:lodging) }
    let!(:valid_record) { create(:calendar, user_id: user.id, lodging_id: lodging.id, date: Date.current) }

    it { is_expected.to validate_presence_of(:date) }
    # it { should validate_uniqueness_of(:date).scoped_to(:lodging_id, :user_id) }
  end
end
