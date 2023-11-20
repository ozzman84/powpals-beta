# frozen_string_literal: true

class UsersController < ApplicationController
  # brakeman-disable-all
  before_action :authenticate_account!

  def index
    @users = User.where.not(id: current_account.user.id)
  end

  def show
    @user = current_account.user
  end

  def edit
    @user = current_account.user
  end

  def update
    if current_account.user.update(user_params)
      # redirect_back_or_to user_path
      redirect_to user_path
    else
      flash.now[:errors] = current_account.user.errors.full_messages
      render 'edit'
    end
  end

  private

  def user_params
    params.require(:user).permit(:full_name, :avatar_url, :first_name, :last_name, :account_id, :preferred_name, :about, :ride_type, :level, :phone_number, :address1, :address2, :country, :city,
                                 :state, :zip_code, :birthday, :allergies, :venmo_url, :instagram_url, :facebook_url)
  end
end
