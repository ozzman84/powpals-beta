# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Calendar do
  let(:lodging) do
    create(:lodging, max_guests: 3, max_cars: 1, season_start: Date.current, season_end: Date.current + 30)
  end

  let(:user) { create(:user) }

  it 'rejects stays outside the season' do
    entry = described_class.new(user: user, lodging: lodging, date: Date.current - 1, status: :staying)
    expect(entry).not_to be_valid
    expect(entry.errors[:date]).not_to be_empty
  end

  it 'counts guests when enforcing house capacity' do
    described_class.create!(user: user, lodging: lodging, date: Date.current, status: :staying, guest_count: 2)
    entry = described_class.new(user: create(:user), lodging: lodging, date: Date.current, status: :staying)
    expect(entry).not_to be_valid
    expect(entry.errors[:base]).to include('House capacity would be exceeded')
  end

  it 'allows updating an existing stay without double counting it' do
    entry = described_class.create!(user: user, lodging: lodging, date: Date.current, status: :staying, guest_count: 2)
    expect(entry.update(cars: 1)).to be(true)
  end

  it 'rejects negative guest counts' do
    entry = described_class.new(user: user, lodging: lodging, date: Date.current, status: :staying, guest_count: -1)
    expect(entry).not_to be_valid
  end

  it 'enforces available parking' do
    entry = described_class.new(user: user, lodging: lodging, date: Date.current, status: :staying, cars: 2)
    expect(entry).not_to be_valid
    expect(entry.errors[:cars]).to include('exceed available parking')
  end

  it 'uses users rather than calendar IDs for occupancy avatars' do
    described_class.create!(user: user, lodging: lodging, date: Date.current, status: :staying)
    expect(lodging.calendars.this_week[Date.current][:avatar_urls]).to eq([user.avatar_url])
  end
end
