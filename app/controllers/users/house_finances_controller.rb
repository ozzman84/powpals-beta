# frozen_string_literal: true

module Users
  class HouseFinancesController < ApplicationController
    before_action :authenticate_account!
    before_action :load_finances

    def show
      @entries = @season.house_ledger_entries.includes(:user, :house_payments).order(:month_on, :id)
      @entry_kinds = HouseLedgerEntry.kinds.keys
      @can_record_payments = true
    end

    def update
      values = params.expect(budget: [:monthly_rent, :participant_count]).to_h
      if values.key?('monthly_rent')
        rent = values.delete('monthly_rent')
        values['monthly_rent_cents'] = rent.present? ? HouseMoney.cents(rent) : nil
      end

      success = @season.update(values)
      redirect_to users_lodging_house_season_finance_path(@lodging, @season),
        alert: (success ? nil : @season.errors.full_messages.to_sentence)
    rescue ArgumentError => e
      redirect_to users_lodging_house_season_finance_path(@lodging, @season), alert: e.message
    end

    private

    def load_finances
      @lodging = current_account.user.lodgings.find(params[:lodging_id])
      authorize @lodging, :manage_finances?
      @season = @lodging.house_seasons.find(params[:house_season_id])
    end
  end
end
