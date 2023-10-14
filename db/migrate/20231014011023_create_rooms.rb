class CreateRooms < ActiveRecord::Migration[7.0]
  def change
    create_table :rooms do |t|
      t.belongs_to :lodging, null: false, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end
