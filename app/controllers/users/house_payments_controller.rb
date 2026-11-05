# frozen_string_literal: true

module Users
  class HousePaymentsController < ApplicationController
    before_action :authenticate_account!

    def create
      lodging = current_account.user.lodgings.find(params[:lodging_id])
      permissions = policy(lodging)
      raise Pundit::NotAuthorizedError unless permissions.manage_finances? || permissions.collect_rent?

      season = lodging.house_seasons.find(params[:house_season_id])
      entries = season.house_ledger_entries
      entries = entries.rent_and_deposits unless permissions.manage_finances?
      entry = entries.find(params[:house_ledger_entry_id])
      values = params.expect(house_payment: [:amount, :paid_on, :reference]).to_h
      values['amount_cents'] = HouseMoney.cents(values.delete('amount'))
      entry.record_payment!(values.merge(recorded_by: current_account))
      redirect_to house_money_destination(lodging, season),
        notice: 'Payment recorded. No money was transferred.'
    rescue ArgumentError, ActiveRecord::RecordInvalid => e
      redirect_to house_money_destination(lodging, season),
        alert: e.message
    end
  end
end
