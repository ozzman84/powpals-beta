class CreateSeasonPasses < ActiveRecord::Migration[7.0]
  def up
    create_table :season_passes do |t|
      t.string :name, null: false

      t.timestamps
    end

    ["Epic Pass", "Epic Local Pass", "Ikon Pass", "Ikon Base Pass"].each do |pass|
      SeasonPass.create!(name: pass)
    end
  end

  def down
    drop_table :season_passes
  end
end
