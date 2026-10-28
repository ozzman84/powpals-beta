# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  describe 'relationships' do
    it { is_expected.to have_many(:roommates) }
    it { is_expected.to have_many(:lodgings).through(:roommates) }
    it { is_expected.to belong_to(:account) }
    it { is_expected.to have_many(:calendars).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    # it { should validate_presence_of(:city) }
    # it { should validate_presence_of(:state) }
    it { is_expected.to validate_presence_of(:ride_type) }
    it { is_expected.to validate_length_of(:first_name).is_at_least(2) }
    it { is_expected.to validate_length_of(:last_name).is_at_least(2) }
    # it { should validate_length_of(:city).is_at_least(2) }
    # it { should validate_length_of(:state).is_at_least(2) }
  end
end
