# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HistoricalHouseImport do
  def snapshot_for(house)
    records = {
      'accounts' => house.users.map(&:account), 'users' => house.users.to_a,
      'lodgings' => [house], 'roommates' => house.roommates.to_a,
      'rooms' => house.rooms.to_a, 'beds' => house.rooms.flat_map(&:beds), 'calendars' => house.calendars.to_a
    }
    { 'version' => 1, 'tables' => records.transform_values { |rows| rows.map(&:attributes) } }
  end

  def historical_snapshot
    result = nil
    ApplicationRecord.transaction(requires_new: true) do
      house = create(:lodging, title: 'Bear Lodge')
      user = create(:user)
      create(:roommate, lodging: house, user: user, role: :roommate)
      create(:calendar, lodging: house, user: user, date: Date.new(2023, 11, 1), status: :staying)
      result = snapshot_for(house)
      raise ActiveRecord::Rollback
    end
    result
  end

  it 'dry-runs inserts and leaves the destination unchanged' do
    snapshot = historical_snapshot
    expect(described_class.new(snapshot).call.fetch('calendars')).to eq(1)
    expect(Lodging.count).to eq(0)
    expect(Account.count).to eq(0)
  end

  it 'preserves source IDs and history without granting manager access' do
    snapshot = historical_snapshot
    snapshot['tables']['roommates'].first['role'] = nil
    snapshot['tables']['calendars'].first['cars'] = nil
    snapshot['tables']['accounts'].first['reset_password_token'] = 'old-token'
    counts = described_class.new(snapshot).call(apply: true)
    expect(counts.fetch('calendars')).to eq(1)
    expect(Lodging.first.id).to eq(snapshot['tables']['lodgings'].first['id'])
    expect(Calendar.first.date).to eq(Date.new(2023, 11, 1))
    expect(Calendar.first.cars).to eq(0)
    expect(Roommate.first.role).to eq('roommate')
    expect(Account.first.reset_password_token).to be_nil
    expect(snapshot['tables']['roommates'].first['role']).to be_nil
  end

  it 'preserves PostgreSQL UTC timestamps regardless of the app time zone' do
    snapshot = historical_snapshot
    snapshot['tables']['lodgings'].first['created_at'] = '2023-11-01 12:00:00.123456'
    described_class.new(snapshot).call(apply: true)
    expect(Lodging.first.created_at.utc).to eq(Time.iso8601('2023-11-01T12:00:00.123456Z'))
  end

  it 'refuses to overwrite a nonempty destination' do
    snapshot = historical_snapshot
    create(:lodging)
    expect { described_class.new(snapshot).call(apply: true) }.to raise_error(ArgumentError, /empty destination/)
    expect(Lodging.count).to eq(1)
    expect(Account.count).to eq(0)
  end

  it 'rolls back the entire import when identities conflict' do
    snapshot = historical_snapshot
    duplicate = snapshot['tables']['users'].first.merge('id' => 999_999)
    snapshot['tables']['users'] << duplicate
    expect { described_class.new(snapshot).call(apply: true) }.to raise_error(ActiveRecord::RecordNotUnique)
    expect(Account.count).to eq(0)
    expect(Lodging.count).to eq(0)
  end

  it 'rejects snapshots containing unconfirmed houses' do
    snapshot = historical_snapshot
    snapshot['tables']['lodgings'].first['title'] = 'Demo house'
    expect { described_class.new(snapshot).call(apply: true) }.to raise_error(ArgumentError, /Bear Lodge/)
    expect(Account.count).to eq(0)
  end
end
