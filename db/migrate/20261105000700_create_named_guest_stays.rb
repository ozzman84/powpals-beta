# frozen_string_literal: true

class CreateNamedGuestStays < ActiveRecord::Migration[8.1]
  def change
    create_table :guest_stays do |t|
      t.references :house_season, null: false, foreign_key: true
      t.references :host, null: false, foreign_key: { to_table: :users }
      t.references :guest, foreign_key: { to_table: :users }
      t.string :guest_name, null: false
      t.string :email, null: false
      t.date :arrival, null: false
      t.date :departure, null: false
      t.integer :cars, null: false, default: 0
      t.string :status, null: false, default: 'requested'
      t.string :token_digest, null: false
      t.datetime :expires_at, null: false
      t.datetime :accepted_at
      t.timestamps
    end
    add_index :guest_stays, :token_digest, unique: true
    add_check_constraint :guest_stays, 'departure > arrival AND cars >= 0', name: 'valid_guest_stay'
    add_reference :bed_requests, :guest_stay, foreign_key: true
  end
end
