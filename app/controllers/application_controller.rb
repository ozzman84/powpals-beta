# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError do
    head :forbidden
  end

  private

  def house_money_destination(lodging, season)
    if policy(lodging).manage_finances?
      users_lodging_house_season_finance_path(lodging, season)
    else
      users_lodging_house_season_rent_collection_path(lodging, season)
    end
  end

  def pundit_user
    current_account
  end
end
