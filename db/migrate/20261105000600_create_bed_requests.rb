# frozen_string_literal: true

class CreateBedRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :bed_requests do |t|
      t.references :bed, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.date :arrival, null: false
      t.date :departure, null: false
      t.integer :spaces, null: false, default: 1
      t.string :status, null: false, default: 'requested'
      t.timestamps
    end
    add_index :bed_requests, [:bed_id, :arrival, :departure]
    add_check_constraint :bed_requests, 'departure > arrival AND spaces > 0', name: 'valid_bed_request'
  end
end
