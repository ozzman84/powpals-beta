class AddCapacityToBeds < ActiveRecord::Migration[7.0]
  def change
    add_column :beds, :capacity, :integer
  end
end
