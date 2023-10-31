class RemoveDeviseAttributesFromUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :email, :string
    remove_column :users, :encrypted_password, :string
    remove_column :users, :uid, :string
    remove_column :users, :provider, :string
    remove_column :users, :reset_password_token, :string
    remove_column :users, :reset_password_sent_at, :datetime
    remove_column :users, :remember_created_at, :datetime
    remove_column :users, :sign_in_count, :integer
    remove_column :users, :current_sign_in_at, :datetime
    remove_column :users, :last_sign_in_at, :datetime
    remove_column :users, :current_sign_in_ip, :string
    remove_column :users, :last_sign_in_ip, :string
    remove_column :users, :confirmation_token, :string
    remove_column :users, :confirmed_at, :datetime
    remove_column :users, :confirmation_sent_at, :datetime
    remove_column :users, :unconfirmed_email, :string
    remove_column :users, :failed_attempts, :integer
    remove_column :users, :unlock_token, :string
    remove_column :users, :locked_at, :datetime
  end
end
