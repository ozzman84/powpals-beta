class AddGuestCountToCalendars < ActiveRecord::Migration[7.0]
  def change
    add_column :calendars, :guest_count, :integer
  end
end
