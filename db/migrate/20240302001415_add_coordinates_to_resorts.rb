class AddCoordinatesToResorts < ActiveRecord::Migration[7.0]
  def change
    add_column :resorts, :lat, :decimal, precision: 10, scale: 6
    add_column :resorts, :long, :decimal, precision: 10, scale: 6
  end
end
