# frozen_string_literal: true

class ExtendSleepingInventory < ActiveRecord::Migration[8.1]
  def change
    add_column :beds, :label, :string
    add_column :beds, :temporary, :boolean, null: false, default: false
    add_column :beds, :notes, :text
    add_column :rooms, :layout_notes, :text
    add_column :lodgings, :layout_reference_url, :string
  end
end
