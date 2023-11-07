# frozen_string_literal: true

module Users
  class CalendarsController < ApplicationController
    before_action :authenticate_account!

    def show
      @lodging = current_account.user.lodgings.find(params[:lodging_id])
      @lodging_calendars = @lodging.calendars.grouped_by_date_with_avatars(params[:start_date]&.to_date || Date.today)
    end

    def my_calendar
      @lodging = current_account.user.lodgings.find(params[:lodging_id])
      @calendars = current_account.user.calendars.where(lodging_id: params[:lodging_id])
    end

    def create
      @calendar = current_account.user.calendars.new(create_calendar_params.except(:start_date))

      if @calendar.save
        redirect_to my_calendar_users_lodging_calendars_path(start_date: create_calendar_params[:start_date])
      else
        flash.now[:errors] = @calendar.errors.full_messages
      end
    end

    def update
      @calendar = current_account.user.calendars.find(params[:id])

      if @calendar.update(update_calendar_params.except(:start_date))
        redirect_to my_calendar_users_lodging_calendars_path(start_date: update_calendar_params[:start_date])
      else
        flash.now[:errors] = @calendar.errors.full_messages
      end
    end

    def destroy
      @calendar = current_account.user.calendars.find(params[:id])

      if @calendar.destroy
        redirect_to my_calendar_users_lodging_calendars_path(start_date: params[:start_date])
      else
        flash.now[:errors] = @calendar.errors.full_messages
      end
    end

    private

    def calendar_params
      params.require(:calendar).permit(:date, :lodging_id, :status, :start_date)
    end

    def update_calendar_params
      params.require(:calendar).permit(:status, :start_date)
    end
  end
end
