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
      @calendar = current_user.lodging_calendars.new(create_lodging_params)

      flash[:errors] = @calendar.errors.full_messages unless @calendar.save

      redirect_to users_lodging_lodging_calendars_path(id: params[:originating_id])
    end

    def update
      @calendar = current_user.lodging_calendars.find(params[:id])

      if params[:status] != @calendar.status
        flash[:alert] = 'Values are the same. Update not processed.'
      end

      flash[:errors] = @calendar.errors.full_messages unless @calendar.update(status: params[:status])

      redirect_to users_lodging_lodging_calendars_path
    end

    def destroy
      @calendar = current_user.lodging_calendars.find(params[:id])
      @calendar.destroy

      redirect_to users_lodging_lodging_calendar_path(id: params[:originating_id])
    end

    private

    def create_lodging_params
      params.permit(:lodging_id, :user_id, :start_date, :end_date, :status)
    end

    def update_calendar_params
      params.permit(:status)
    end
  end
end
