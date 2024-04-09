class AddCarsToCalendars < ActiveRecord::Migration[7.0]
  def change
    add_column :calendars, :cars, :integer
  end
end
