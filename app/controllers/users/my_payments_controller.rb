# frozen_string_literal: true

module Users
  class MyPaymentsController < ApplicationController
    before_action :authenticate_account!

    def show
      @lodging = current_account.user.lodgings.find(params[:lodging_id])
      authorize @lodging, :my_payments?
      @seasons = @lodging.house_seasons.order(starts_on: :desc)
      @season = if params[:season_id].present?
                  @seasons.find(params[:season_id])
                else
                  @seasons.find_by(starts_on: @lodging.season_start, ends_on: @lodging.season_end) || @seasons.first
                end

      @entries = if @season
                   @season.house_ledger_entries.where(user_id: current_account.user.id)
                     .includes(:user, :house_payments).order(:month_on, :id)
                 else
                   HouseLedgerEntry.none
                 end

      @can_record_payments = false
    end
  end
end
