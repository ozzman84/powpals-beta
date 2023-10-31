class AddColumnProviderToAccounts < ActiveRecord::Migration[7.0]
  def change
    add_column :accounts, :provider, :string
  end
end
