# frozen_string_literal: true

class AddPrivateMemberFinances < ActiveRecord::Migration[8.1]
  def change
    add_reference :house_ledger_entries, :user, foreign_key: true
    add_column :house_ledger_entries, :due_on, :date
    add_index :roommates, :lodging_id, unique: true, where: "role = 'accountant'", name: 'one_accountant_per_house'
  end
end
