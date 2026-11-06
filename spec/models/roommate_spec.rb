# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Roommate do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:lodging) }

  it 'rejects a second membership for the same person and house' do
    user = create(:user)
    lodging = create(:lodging)
    described_class.create!(user: user, lodging: lodging, role: :roommate)
    duplicate = described_class.new(user: user, lodging: lodging, role: :roommate)
    expect(duplicate).not_to be_valid
  end
end
