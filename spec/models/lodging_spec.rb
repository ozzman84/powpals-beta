# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Lodging do
  describe 'relationships' do
    it { is_expected.to have_many(:roommates) }
    it { is_expected.to have_many(:users).through(:roommates) }
    it { is_expected.to have_many(:rooms) }
    it { is_expected.to have_many(:calendars).dependent(:destroy) }
  end

  describe 'Full address' do
    let(:nil_address2) do
      {
        street: '1234 Main St',
        address2: nil,
        city: 'Denver',
        state: 'CO',
        zip_code: '80205'
      }
    end

    it 'returns the full address' do
      lodging = create(:lodging, nil_address2)

      expect(lodging.full_address).to eq('1234 Main St Denver, CO 80205')
    end

    it 'returns the full address' do
      lodging = create(:lodging, nil_address2.merge(address2: 'apt 4'))

      expect(lodging.full_address).to eq('1234 Main St apt 4 Denver, CO 80205')
    end
  end
end
