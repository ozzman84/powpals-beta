# frozen_string_literal: true

class SeasonalizeOwnedPasses < ActiveRecord::Migration[8.1]
  def up
    add_column :account_season_passes, :starts_on, :date
    add_column :account_season_passes, :expires_on, :date
    add_column :account_season_passes, :season_label, :string
    add_column :account_season_passes, :season_unknown, :boolean, default: false, null: false
    execute 'UPDATE account_season_passes SET season_unknown = TRUE'
    remove_index :account_season_passes, name: 'unique_account_season_passes_identity'
    add_index :account_season_passes, [:account_id, :season_pass_id, :starts_on], unique: true,
      where: 'starts_on IS NOT NULL', name: 'unique_owned_pass_season'
    add_index :account_season_passes, [:account_id, :season_pass_id], unique: true,
      where: 'season_unknown = TRUE', name: 'unique_undated_owned_pass'
    add_check_constraint :account_season_passes,
      '(season_unknown AND starts_on IS NULL AND expires_on IS NULL) OR ' \
      '(NOT season_unknown AND starts_on IS NOT NULL AND expires_on IS NOT NULL AND expires_on >= starts_on)',
      name: 'owned_pass_valid_dates'
  end

  def down
    raise ActiveRecord::IrreversibleMigration, 'Do not discard seasonal pass history'
  end
end
