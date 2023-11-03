# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Calendar, type: :model do
  describe 'Relationships' do
    it { should belong_to(:user).dependent(:destroy) }
    it { should belong_to(:lodging).dependent(:destroy) }
  end

  describe 'Validations' do
    let(:user) { create(:user, account_id: create(:account).id) }
    let!(:valid_record) { create(:calendar, user_id: user.id, lodging_id: create(:lodging).id, date: Date.today) }

    it { should validate_presence_of(:date) }
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:lodging_id) }
    # it { should validate_uniqueness_of(:date).scoped_to(:lodging_id, :user_id) }
  end
end
