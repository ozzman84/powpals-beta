# frozen_string_literal: true

class LinkGuestChargesAndPayments < ActiveRecord::Migration[8.1]
  def change
    add_reference :house_ledger_entries, :guest_stay, foreign_key: true
    add_column :house_ledger_entries, :voided_at, :datetime
    add_reference :house_payments, :paid_by, foreign_key: { to_table: :users }
    add_column :guest_stays, :billed_at, :datetime
    add_column :guest_stays, :dogs, :integer, default: 0, null: false
    add_index :house_ledger_entries, [:guest_stay_id, :month_on], unique: true,
      where: 'guest_stay_id IS NOT NULL', name: 'unique_guest_stay_month_charge'
  end
end
