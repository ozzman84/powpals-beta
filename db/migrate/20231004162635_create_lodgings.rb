class CreateLodgings < ActiveRecord::Migration[7.0]
  def change
    create_table :lodgings do |t|
      t.string :title
      t.text :description
      t.integer :max_guests
      t.string :street
      t.string :city
      t.string :state
      t.string :zip_code
      t.string :country
      t.decimal :lat, precision: 10, scale: 6
      t.decimal :lon, precision: 10, scale: 6
      t.string :status

      t.timestamps
    end
  end
end
