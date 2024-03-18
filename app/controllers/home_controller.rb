# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @user = current_account.user
    @resorts = current_account.resort_data_for_multiple_days
  end
end
