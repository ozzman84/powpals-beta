class AddAttributesToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :preferred_name, :string
    add_column :users, :about, :string
    add_column :users, :ride_type, :string
    add_column :users, :level, :string
    add_column :users, :phone_number, :string
    add_column :users, :address1, :string
    add_column :users, :address2, :string
    add_column :users, :country, :string
    add_column :users, :city, :string
    add_column :users, :state, :string
    add_column :users, :zip_code, :string
    add_column :users, :birthday, :string
    add_column :users, :allergies, :text
    add_column :users, :venmo_url, :string
    add_column :users, :instagram_url, :string
    add_column :users, :facebook_url, :string
  end
end
