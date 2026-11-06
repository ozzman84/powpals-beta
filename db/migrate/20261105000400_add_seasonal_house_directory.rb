# frozen_string_literal: true

class AddSeasonalHouseDirectory < ActiveRecord::Migration[8.1]
  def change
    add_column :roommates, :access_state, :string, null: false, default: 'active'
    add_reference :house_invitations, :house_season, foreign_key: true
    create_table :house_season_memberships do |t|
      t.references :house_season, null: false, foreign_key: true
      t.references :roommate, null: false, foreign_key: true
      t.string :status, null: false, default: 'active'
      t.text :responsibilities
      t.text :pets
      t.text :pet_rules
      t.text :preferences
      t.boolean :share_contact, null: false, default: false
      t.timestamps
    end
    add_index :house_season_memberships, [:house_season_id, :roommate_id], unique: true,
      name: 'unique_season_member'
  end
end
