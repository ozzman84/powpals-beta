class ChangeAccountIdToNullFalseFromUsers < ActiveRecord::Migration[7.0]
  def change
    change_column :users, :account_id, :bigint, null: false
  end
end
