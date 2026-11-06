# frozen_string_literal: true

module Users
  class HouseLedgerEntriesController < ApplicationController
    before_action :authenticate_account!

    def create
      lodging = current_account.user.lodgings.find(params[:lodging_id])
      permissions = policy(lodging)
      raise Pundit::NotAuthorizedError unless permissions.manage_finances? || permissions.collect_rent?

      season = lodging.house_seasons.find(params[:house_season_id])
      values = params.expect(house_ledger_entry: [:kind, :description, :month_on, :amount, :user_id, :due_on]).to_h
      raise Pundit::NotAuthorizedError if !permissions.manage_finances? && %w[rent deposit].exclude?(values['kind'])

      member_id = values.delete('user_id')
      values['user'] = lodging.users.find(member_id) if member_id.present?
      values['amount_cents'] = HouseMoney.cents(values.delete('amount'))
      entry = season.house_ledger_entries.new(values.merge(recorded_by: current_account))
      success = entry.save
      redirect_to house_money_destination(lodging, season),
        alert: (success ? nil : entry.errors.full_messages.to_sentence)
    rescue ArgumentError => e
      redirect_to house_money_destination(lodging, season),
        alert: e.message
    end
  end
end
