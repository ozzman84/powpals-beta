class CreateCalendars < ActiveRecord::Migration[7.0]
  def change
    create_table :calendars do |t|
      t.string :status
      t.date :date
      t.references :user, null: false, foreign_key: true
      t.references :lodging, null: false, foreign_key: true

      t.timestamps
    end
  end
end
