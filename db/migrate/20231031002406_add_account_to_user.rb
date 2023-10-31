class AddAccountToUser < ActiveRecord::Migration[7.0]
  def change
    add_reference :users, :account, null: true, foreign_key: true
  end
end
