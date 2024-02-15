class CreateAccountSkiDays < ActiveRecord::Migration[7.0]
  def change
    create_table :account_ski_days do |t|
      t.string :status
      t.date :start_date
      t.references :account, null: false, foreign_key: true
      t.references :resort, null: false, foreign_key: true

      t.timestamps
    end
  end
end
