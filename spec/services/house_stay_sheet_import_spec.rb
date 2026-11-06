# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HouseStaySheetImport do
  let(:house) { create(:lodging) }
  let(:sheet) do
    [
      ['Day Plan', '', '', 'Friday', 'Saturday'],
      ['0 away, 1 staying, plus guests', '', '', '11/1/2024', '11/2/2024'],
      ['1', 'Source name', '', '', '0'],
      ['2', 'Another source name', '', '3', ''],
      ['Bed Reserve', '', '', '', ''],
      ['', '', '', '11/1/2023', '11/2/2023'],
      ['1', 'Master', 'King', 'TBD / guests', '']
    ].map { |row| row.join("\t") }.join("\n")
  end

  it 'keeps separate source years, preserves explicit zero, and creates no users or live stays' do
    accounts = Account.count
    result = described_class.new(house, source_key: 'test').call(sheet)
    expect(result).to eq(cells: 3, seasons: 2)
    expect(Account.count).to eq(accounts)
    expect(Calendar.count).to eq(0)
    expect(house.house_seasons.order(:starts_on).pluck(:starts_on)).to eq([Date.new(2023, 11, 1),
      Date.new(2024, 11, 1)])
    expect(HouseSheetCell.stay_observation.pluck(:value)).to contain_exactly('0', '3')
    expect(HouseSheetCell.bed_request.first.value).to eq('TBD / guests')
  end

  it 'can repeat an import without duplicating source cells' do
    2.times { described_class.new(house, source_key: 'test').call(sheet) }
    expect(HouseSheetCell.count).to eq(3)
  end

  it 'rolls back revisions that change or remove existing populated cells' do
    described_class.new(house, source_key: 'test').call(sheet)
    expect do
      described_class.new(house, source_key: 'test').call(sheet.sub('TBD / guests', 'Different label'))
    end.to raise_error(ArgumentError, /Source cell changed/)
    expect do
      described_class.new(house, source_key: 'test').call(sheet.sub('TBD / guests', ''))
    end.to raise_error(ArgumentError, /removed previously/)
    expect(HouseSheetCell.bed_request.first.value).to eq('TBD / guests')
  end

  it 'rejects unclear day-plan values without importing partial records' do
    expect do
      described_class.new(house, source_key: 'test').call(sheet.sub("3\t", "maybe\t"))
    end.to raise_error(ArgumentError, /Day-plan cells/)
    expect(HouseSheetCell.count).to eq(0)
  end
end
