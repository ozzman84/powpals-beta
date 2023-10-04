class AddOmniauthColumnsToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string

    add_index :users, :uid
    add_index :users, [:provider, :uid]
  end
end
