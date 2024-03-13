# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountSkiDay, type: :model do
  it { should belong_to(:resort) }
  it { should belong_to(:account) }

  describe 'validations' do
    subject { AccountSkiDay.create(account_id: create(:account).id, resort_id: create(:resort).id) }
    it { should validate_uniqueness_of(:start_date).scoped_to(:account_id, :resort_id) }
  end
end
