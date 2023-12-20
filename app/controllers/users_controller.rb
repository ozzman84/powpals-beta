# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_account!
  before_action :add_avatar_url, on: :update

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
    current_account.user.avatar_url.attach(user_params[:avatar_url]) if user_params[:avatar_url]

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
    params.require(:user).permit(:full_name, :avatar_url, :first_name, :last_name, :preferred_name, :about, :ride_type, :level, :phone_number, :address1, :address2, :country, :city,
                                 :state, :zip_code, :birthday, :allergies, :venmo_url, :instagram_url, :facebook_url)
  end

  def add_avatar_url
    # current_account.user.avatar_url.attach(params[:user][:avatar_url]) if params[:user][:avatar_url].present?
  end
end
