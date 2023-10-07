class AddStreet2ToBeStringInLodging < ActiveRecord::Migration[7.0]
  def change
    add_column :lodgings, :address2, :string
  end
end
