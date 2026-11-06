# frozen_string_literal: true

class AddHouseOperations < ActiveRecord::Migration[8.1]
  def change
    create_table :house_seasons do |t|
      t.references :lodging, null: false, foreign_key: true
      t.string :name, null: false
      t.date :starts_on, null: false
      t.date :ends_on, null: false
      t.string :policy_status, default: 'draft', null: false
      t.bigint :monthly_rent_cents
      t.integer :participant_count
      t.jsonb :guest_rates, default: {}, null: false
      t.bigint :dog_fee_cents
      t.string :dog_fee_basis, default: 'unconfirmed', null: false
      t.integer :free_nights, default: 0, null: false
      t.text :rules
      t.text :source_notes
      t.jsonb :source_summary, default: {}, null: false
      t.timestamps
    end
    add_index :house_seasons, [:lodging_id, :starts_on, :ends_on], unique: true, name: 'unique_house_season_dates'
    add_check_constraint :house_seasons, 'ends_on >= starts_on', name: 'house_season_date_order'
    create_table :house_ledger_entries do |t|
      t.references :house_season, null: false, foreign_key: true
      t.references :recorded_by, foreign_key: { to_table: :accounts }
      t.string :kind, null: false
      t.string :description, null: false
      t.date :month_on, null: false
      t.bigint :amount_cents, null: false
      t.string :source_key
      t.jsonb :source_data, default: {}, null: false
      t.timestamps
    end
    add_index :house_ledger_entries, [:house_season_id, :source_key], unique: true
    add_check_constraint :house_ledger_entries, 'amount_cents > 0', name: 'house_ledger_positive_amount'
    create_table :house_payments do |t|
      t.references :house_ledger_entry, null: false, foreign_key: true
      t.references :recorded_by, foreign_key: { to_table: :accounts }
      t.bigint :amount_cents, null: false
      t.date :paid_on
      t.boolean :source_reported, default: false, null: false
      t.string :reference
      t.timestamps
    end
    add_check_constraint :house_payments, 'amount_cents > 0', name: 'house_payment_positive_amount'
    create_table :house_sheet_cells do |t|
      t.references :house_season, null: false, foreign_key: true
      t.string :kind, null: false
      t.date :observed_on, null: false
      t.string :person_label
      t.string :room_label
      t.string :bed_label
      t.string :value, null: false
      t.string :source_key, null: false
      t.timestamps
    end
    add_index :house_sheet_cells, [:house_season_id, :source_key], unique: true
  end
end
