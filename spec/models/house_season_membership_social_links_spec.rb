# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HouseSeasonMembership do
  it 'accepts arbitrary HTTPS platforms and rejects unsafe URLs and excessive links' do
    house = create(:lodging)
    member = create(:roommate, lodging: house)
    season = house.house_seasons.create!(name: 'Winter', starts_on: Date.current, ends_on: Date.current + 30)
    record = season.house_season_memberships.new(roommate: member)
    ['javascript:alert(1)', 'http://example.com/', 'https://name:password@example.com/', 'https://',
      'https://bad host.example/'].each do |url|
      record.social_links = [{ label: 'Website', url: url, shared: true }]
      expect(record).not_to be_valid
    end
    record.social_links = Array.new(10) { { label: 'Website', url: 'https://example.com/', shared: true } }
    expect(record).to be_valid
    record.social_links = Array.new(11) { { label: 'Website', url: 'https://example.com/', shared: true } }
    expect(record).not_to be_valid
    record.social_links = [{ label: 'Bluesky', url: 'https://bsky.app/', shared: 'false' }]
    expect(record).to be_valid
    expect(record.shared_social_links).to be_empty
    record.social_links = [{ label: '', url: '', shared: false }]
    expect(record).to be_valid
    expect(record.social_links).to be_empty
  end
end
