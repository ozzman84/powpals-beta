# frozen_string_literal: true

class StrengthenHouseData < ActiveRecord::Migration[7.0]
  INDEXES = {
    roommates: %i[lodging_id user_id], calendars: %i[lodging_id user_id date],
    account_season_passes: %i[account_id season_pass_id], season_pass_resorts: %i[season_pass_id resort_id],
    users: [:account_id], account_ski_days: %i[account_id resort_id start_date], accounts: %i[provider uid]
  }.freeze

  def up
    INDEXES.each do |table, columns|
      names = columns.map { |column| quote_column_name(column) }.join(', ')
      duplicates = select_value("SELECT COUNT(*) FROM (SELECT #{names} FROM #{quote_table_name(table)} WHERE #{columns.map { |c| "#{quote_column_name(c)} IS NOT NULL" }.join(' AND ')} GROUP BY #{names} HAVING COUNT(*) > 1) duplicates")
      raise "Duplicate #{table} records must be reviewed before adding constraints" if duplicates.to_i.positive?

      add_index table, columns, unique: true, name: "unique_#{table}_identity"
    end
    add_column :lodgings, :season_start, :date
    add_column :lodgings, :season_end, :date
    add_column :lodgings, :max_cars, :integer
    %i[guest_count cars].each do |column|
      execute "UPDATE calendars SET #{column} = 0 WHERE #{column} IS NULL"
      change_column_default :calendars, column, from: nil, to: 0
      change_column_null :calendars, column, false
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, 'Season data must not be discarded automatically'
  end
end
