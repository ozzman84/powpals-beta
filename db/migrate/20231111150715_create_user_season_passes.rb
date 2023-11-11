class CreateUserSeasonPasses < ActiveRecord::Migration[7.0]
  def change
    create_table :user_season_passes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :season_pass, null: false, foreign_key: true

      t.timestamps
    end
  end
end
