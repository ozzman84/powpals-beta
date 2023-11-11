class CreateSeasonPasses < ActiveRecord::Migration[7.0]
  def change
    create_table :season_passes do |t|
      t.string :name, null: false

      t.timestamps
    end
  end
end
