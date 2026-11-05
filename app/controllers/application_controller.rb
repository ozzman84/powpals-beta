# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :require_house_access!

  def require_house_access!
    return unless controller_path.start_with?('users/') && account_signed_in?
    return if current_account.user&.house_access?

    head :forbidden
  end

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
