# frozen_string_literal: true

class AccountsController < ApplicationController
  before_action :authenticate_account!

  def update
    if current_account.with_lock { current_account.update(account_params) }
      flash[:notice] = 'Updated!'
    else
      flash[:alert] = current_account.errors.full_messages.to_sentence
    end

    redirect_to edit_profile_path
  end

  def season_pass_destroy
    account_season_pass = if params[:id]
                            current_account.account_season_passes.find(params[:id])
                          else
                            current_account.account_season_passes.find_by(season_pass_id: params[:season_pass_id])
                          end

    account_season_pass&.destroy
    redirect_to edit_profile_path
  end

  private

  def account_params
    params.expect(account: [account_season_passes_attributes: [%i[season_pass_id id starts_on expires_on
      season_label]]])
  end
end
