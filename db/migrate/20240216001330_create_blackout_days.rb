class CreateBlackoutDays < ActiveRecord::Migration[7.0]
  def change
    create_table :blackout_days do |t|
      t.date :start_date
      t.date :end_date
      t.references :season_pass, null: false, foreign_key: true
      t.references :resort, null: false, foreign_key: true

      t.timestamps
    end
  end
end
