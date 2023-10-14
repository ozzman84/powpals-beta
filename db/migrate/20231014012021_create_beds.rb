class CreateBeds < ActiveRecord::Migration[7.0]
  def change
    create_table :beds do |t|
      t.belongs_to :room, null: false, foreign_key: true
      t.string :size
      t.string :style

      t.timestamps
    end
  end
end
