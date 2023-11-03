# frozen_string_literal: true

module Users
  class CalendarsController < ApplicationController
    before_action :authenticate_account!

    def show; end

    def my_calendar
      @lodging = current_account.user.lodgings.find(params[:lodging_id])
      @calendar = current_account.user.calendars.where(lodging_id: params[:lodging_id])
    end

    def create
      @calendar = current_account.user.calendars.new(create_calendar_params)

      if @calendar.save
        redirect_to my_calendar_users_lodging_calendars_path
      else
        flash.now[:errors] = @calendar.errors.full_messages
      end
    end

    def update
      @calendar = current_account.user.calendars.find(params[:id])

      if @calendar.update(update_calendar_params)
        redirect_to my_calendar_users_lodging_calendars_path
      else
        flash.now[:errors] = @calendar.errors.full_messages
      end
    end

    def destroy
      @calendar = current_account.user.calendars.find(params[:id])

      if @calendar.destroy
        redirect_to my_calendar_users_lodging_calendars_path
      else
        flash.now[:errors] = @calendar.errors.full_messages
      end
    end

    private

    def create_calendar_params
      params.require(:calendar).permit(:date, :lodging_id, :status)
    end

    def update_calendar_params
      params.require(:calendar).permit(:status)
    end
  end
end
