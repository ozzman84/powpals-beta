# frozen_string_literal: true

class GuestVisitsController < ApplicationController
  before_action :authenticate_account!

  def index
    @stays = GuestStay.where(guest: current_account.user).includes(:house_season, :host).order(:arrival)
  end

  def show
    @stay = GuestStay.where(guest: current_account.user).find(params[:id])
  end
end
