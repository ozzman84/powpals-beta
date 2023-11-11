class CreateAccountSeasonPasses < ActiveRecord::Migration[7.0]
  def change
    create_table :account_season_passes do |t|
      t.references :account, null: false, foreign_key: true
      t.references :season_pass, null: false, foreign_key: true

      t.timestamps
    end
  end
end
