# frozen_string_literal: true

class HouseAttendance
  def initialize(calendars, lodging: nil)
    @calendars = calendars
    @lodging = lodging
  end

  def call(dates)
    entries = @calendars.where(date: dates).includes(:user).group_by(&:date)
    visits = if @lodging
               @lodging.guest_stays.approved.includes(:guest)
                   .where('arrival <= ? AND departure > ?', dates.last, dates.first).to_a
             else
               []
             end

    dates.index_with do |date|
      counts(entries.fetch(date, []), visits.select do |v|
        v.arrival <= date && v.departure > date
      end)
    end
  end

  private

  def counts(entries, visits)
    staying = entries.select(&:staying?)
    people = staying.map { |entry| { user: entry.user, name: entry.user.attendance_name, guest: false } } +
      visits.map { |visit| { user: visit.guest, name: visit.guest&.attendance_name || visit.guest_name, guest: true } }
    { away: entries.count(&:away?), staying: staying.size,
      guests: staying.sum(&:guest_count) + visits.size,
      cars: staying.sum(&:cars) + visits.sum(&:cars), attendees: people,
      avatar_urls: staying.filter_map { |entry| entry.user.avatar_url } }
  end
end
