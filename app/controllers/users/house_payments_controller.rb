# frozen_string_literal: true

module Users
  class HousePaymentsController < ApplicationController
    before_action :authenticate_account!

    def create
      lodging = current_account.user.lodgings.find(params[:lodging_id])
      authorize lodging, :update?
      season = lodging.house_seasons.find(params[:house_season_id])
      entry = season.house_ledger_entries.find(params[:house_ledger_entry_id])
      values = params.expect(house_payment: [:amount, :paid_on, :reference]).to_h
      values['amount_cents'] = HouseMoney.cents(values.delete('amount'))
      entry.record_payment!(values.merge(recorded_by: current_account))
      redirect_to users_lodging_house_season_path(lodging, season),
        notice: 'Payment recorded. No money was transferred.'
    rescue ArgumentError, ActiveRecord::RecordInvalid => e
      redirect_to users_lodging_house_season_path(lodging, season), alert: e.message
    end
  end
end
