# frozen_string_literal: true

class AccountsController < ApplicationController
  before_action :authenticate_account!

  def update
    if current_account.update(account_params)
      flash[:notice] = "Updated!"
    else
      flash[:alert] = "Something went wrong!"
    end
    redirect_to edit_profile_path
  end

  def season_pass_destroy
    account_season_pass = current_account.account_season_passes.find_by(season_pass_id: params[:season_pass_id])
    account_season_pass&.destroy
    redirect_to edit_profile_path
  end

  private

  def account_params
    params.
      require(:account).
      permit(
        :email,
        account_season_passes_attributes: [
          :account_id,
          :season_pass_id,
          :id
        ]
      )
  end
end