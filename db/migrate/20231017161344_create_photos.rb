class CreatePhotos < ActiveRecord::Migration[7.0]
  def change
    create_table :photos do |t|
      t.references :lodging, null: false, foreign_key: true
      t.string :caption

      t.timestamps
    end
  end
end
