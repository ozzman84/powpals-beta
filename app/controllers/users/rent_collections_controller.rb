# frozen_string_literal: true

module Users
  class RentCollectionsController < ApplicationController
    before_action :authenticate_account!

    def show
      @lodging = current_account.user.lodgings.find(params[:lodging_id])
      authorize @lodging, :collect_rent?
      @season = @lodging.house_seasons.find(params[:house_season_id])
      @entries = @season.house_ledger_entries.rent_and_deposits.includes(:user, :house_payments).order(:month_on, :id)
      @entry_kinds = %w[rent deposit]
      @can_record_payments = true
    end
  end
end
