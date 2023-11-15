# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Calendar, type: :model do
  describe 'Relationships' do
    it { should belong_to(:user) }
    it { should belong_to(:lodging) }
  end

  describe 'Validations' do
    let(:user) { create(:user, account_id: create(:account).id) }
    let(:lodging) { create(:lodging) }
    let!(:valid_record) { create(:calendar, user_id: user.id, lodging_id: lodging.id, date: Date.today) }

    it { should validate_presence_of(:date) }
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:lodging_id) }
    # it { should validate_uniqueness_of(:date).scoped_to(:lodging_id, :user_id) }

    context '#this_week' do
      let(:user2) { create(:user, account_id: create(:account).id) }
      let!(:valid_record2) { create(:calendar, user_id: user2.id, lodging_id: lodging.id, date: Date.today) }

      # it 'returns status and role count for each day' do
      #   binding.pry
      #   expect(0).to eq(1)
      # end
    end
  end
end
