# frozen_string_literal: true

module Users
  class LodgingCalendarsController < ApplicationController
    before_action :authenticate_user!

    def index
      @lodging = current_user.lodgings.find(params[:lodging_id])
      @calendars = @lodging.lodging_calendars
    end

    def show
      @lodging = current_user.lodgings.find(params[:lodging_id])
      @user_calendars = current_user.lodging_calendars
    end

    def create
      puts params
      @calendar = current_user.lodging_calendars.new(create_lodging_params)

      flash[:errors] = @room.errors.full_messages unless @calendar.save

      redirect_to users_lodging_lodging_calendar_path(id: params[:id])
    end

    private

    def create_lodging_params
      params.permit(:lodging_id, :user_id, :start_date, :end_date, :status)
    end
  end
end
