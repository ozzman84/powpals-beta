# frozen_string_literal: true

require 'csv'

# Source labels remain observations: no account matching or guaranteed bed bookings.
class HouseStaySheetImport
  def initialize(lodging, source_key:)
    raise ArgumentError, 'Use a simple stable source key' unless source_key.match?(/\A[a-z0-9_-]+\z/)

    @lodging = lodging
    @source_key = source_key
    @seen = []
    @summaries = {}
  end

  def call(text)
    @lodging.with_lock do
      @kind = 'stay_observation'
      CSV.parse(text, col_sep: "\t").each { |row| import_row(row) }
      reject_removed_cells!
      @summaries.each { |season, summary| season.update!(source_summary: season.source_summary.merge(summary)) }
    end
    { cells: @seen.size, seasons: @summaries.size }
  end

  private

  def import_row(row)
    if row.first.to_s.strip == 'Bed Reserve'
      @kind = 'bed_request'
      @dates = nil
    end

    dates = date_columns(row)
    return set_season(dates) if dates.any?
    return unless @dates && row.first.to_s.strip.match?(/\A\d+\z/)

    import_cells(row)
  end

  def date_columns(row)
    row.each_with_index.filter_map do |cell, index|
      next unless cell.to_s.strip.match?(%r{\A\d{1,2}/\d{1,2}/\d{4}\z})

      [index, Date.strptime(cell.strip, '%m/%d/%Y')]
    end.to_h
  end

  def set_season(dates)
    @dates = dates
    first, last = dates.values.minmax
    @season = @lodging.house_seasons.find_or_create_by!(starts_on: first, ends_on: last) do |season|
      season.name = "Sheet reference #{first.year}–#{last.year}"
      season.policy_status = :reference
      season.source_notes = 'Dates follow this source section, including any May 1 boundary. ' \
        'Blank cells do not mean away. Bed annotations are not guaranteed bookings.'
    end
    @summaries[@season] ||= {}
    @summaries[@season]["#{@kind}_blank_cells"] = 0
    @summaries[@season]["#{@kind}_filled_cells"] = 0
  end

  def import_cells(row)
    @dates.each do |column, date|
      value = row[column].to_s.strip
      summary_key = "#{@kind}_#{value.empty? ? 'blank' : 'filled'}_cells"
      @summaries[@season][summary_key] += 1
      next if value.empty?

      attributes = cell_attributes(row, date, value)
      key = "#{@source_key}:#{@kind}:#{row.first.strip}:#{date.iso8601}"
      cell = @season.house_sheet_cells.find_or_initialize_by(source_key: key)
      raise ArgumentError, 'Source cell changed; review the new revision before importing' if
        cell.persisted? && attributes.any? { |field, expected| cell.public_send(field) != expected }

      cell.update!(attributes) if cell.new_record?
      @seen << cell.id
    end
  end

  def cell_attributes(row, date, value)
    if (@kind == 'stay_observation') && !(value.match?(/\A\d+\z/) && row[1].present?)
      raise ArgumentError, 'Day-plan cells must use 0 for away or a positive total including guests'
    end

    { kind: @kind, observed_on: date, value: value,
      person_label: (@kind == 'stay_observation' ? row[1].to_s.strip : nil),
      room_label: (@kind == 'bed_request' ? row[1].to_s.strip : nil),
      bed_label: (@kind == 'bed_request' ? row[2].to_s.strip : nil) }
  end

  def reject_removed_cells!
    prefix = "#{HouseSheetCell.sanitize_sql_like(@source_key)}:%"
    existing = HouseSheetCell.where(house_season: @lodging.house_seasons).where('source_key LIKE ?', prefix)
    return unless existing.where.not(id: @seen).exists?

    raise ArgumentError, 'Source removed previously imported cells; review before replacing history'
  end
end
