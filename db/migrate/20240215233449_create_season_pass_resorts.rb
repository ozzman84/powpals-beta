class CreateSeasonPassResorts < ActiveRecord::Migration[7.0]
  def change
    create_table :season_pass_resorts do |t|
      t.references :season_pass, null: false, foreign_key: true
      t.references :resort, null: false, foreign_key: true

      t.timestamps
    end
  end
end
