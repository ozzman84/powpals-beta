# frozen_string_literal: true

class CreateHouseInvitations < ActiveRecord::Migration[8.1]
  def change
    create_table :house_invitations do |t|
      t.references :lodging, null: false, foreign_key: true
      t.references :invited_by, null: false, foreign_key: { to_table: :accounts }
      t.string :email, null: false
      t.string :role, null: false, default: 'roommate'
      t.string :token_digest, null: false
      t.datetime :expires_at, null: false
      t.datetime :accepted_at
      t.datetime :revoked_at
      t.timestamps
    end
    add_index :house_invitations, :token_digest, unique: true
  end
end
