# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountSkiDay do
  it { is_expected.to belong_to(:resort) }
  it { is_expected.to belong_to(:account) }

  describe 'validations' do
    subject { described_class.create(account_id: create(:account).id, resort_id: create(:resort).id) }

    it { is_expected.to validate_uniqueness_of(:start_date).scoped_to(:account_id, :resort_id) }
  end
end
