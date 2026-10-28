# frozen_string_literal: true

module Users
  class HouseLedgerEntriesController < ApplicationController
    before_action :authenticate_account!

    def create
      lodging = current_account.user.lodgings.find(params[:lodging_id])
      authorize lodging, :update?
      season = lodging.house_seasons.find(params[:house_season_id])
      values = params.expect(house_ledger_entry: [:kind, :description, :month_on, :amount]).to_h
      values['amount_cents'] = HouseMoney.cents(values.delete('amount'))
      entry = season.house_ledger_entries.new(values.merge(recorded_by: current_account))
      success = entry.save
      redirect_to users_lodging_house_season_path(lodging, season),
        alert: (success ? nil : entry.errors.full_messages.to_sentence)
    rescue ArgumentError => e
      redirect_to users_lodging_house_season_path(lodging, season), alert: e.message
    end
  end
end
