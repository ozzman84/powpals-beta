# frozen_string_literal: true

class AddSocialLinksToSeasonMemberships < ActiveRecord::Migration[8.1]
  def change
    add_column :house_season_memberships, :social_links, :jsonb, default: [], null: false
  end
end
