class ChangeAccountIdToNullFalseFromUsers < ActiveRecord::Migration[7.0]
  def up
    change_column :users, :account_id, :bigint, null: false
  end

  def down
    change_column :users, :account_id, :bigint, null: true
  end
end
