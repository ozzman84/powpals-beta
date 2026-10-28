# frozen_string_literal: true

class UniqueResortAndPassNames < ActiveRecord::Migration[7.0]
  def up
    %i[resorts season_passes].each do |table|
      duplicate = select_value("SELECT COUNT(*) FROM (SELECT LOWER(name) FROM #{table} GROUP BY LOWER(name) HAVING COUNT(*) > 1) duplicates")
      raise "Review duplicate #{table} names before migrating" if duplicate.to_i.positive?

      add_index table, 'LOWER(name)', unique: true, name: "unique_#{table}_name"
    end
  end

  def down
    %i[resorts season_passes].each { |table| remove_index table, name: "unique_#{table}_name" }
  end
end
