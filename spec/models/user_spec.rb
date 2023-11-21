# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'relationships' do
    it { should have_many(:roommates) }
    it { should have_many(:lodgings).through(:roommates) }
    it { should belong_to(:account) }
    it { should have_many(:calendars).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:city) }
    it { should validate_presence_of(:state) }
    it { should validate_presence_of(:ride_type) }
    it { should validate_length_of(:first_name).is_at_least(2) }
    it { should validate_length_of(:last_name).is_at_least(2) }
    it { should validate_length_of(:city).is_at_least(2) }
    it { should validate_length_of(:state).is_at_least(2) }
  end

  describe '#initials' do
    let(:account) { create(:account) }
    let(:user) { create(:user, first_name: 'ozzie', last_name: 'smith') }

    it 'returns capitalized initials' do
      expect(user.initials).to eq('OS')
    end

    it 'returns only last initial' do
      user.update(first_name: nil)

      expect(user.initials).to eq('S')
    end

    it 'returns empty string' do
      user.update(first_name: nil, last_name: nil)

      expect(user.initials).to eq('')
    end
  end
end
