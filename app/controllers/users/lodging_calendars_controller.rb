# frozen_string_literal: true

module Users
  class LodgingCalendarsController < ApplicationController
    def index
      @lodging = current_user.lodgings.find(params[:lodging_id])
      @calendars = @lodging.lodging_calendars
    end

    def show
      @calendar = current_user.lodging_calendars
    end

    def create
      @calendar = current_user.lodging_calendars.new(lodging_params)

      flash[:errors] = @room.errors.full_messages unless @calendar.save

      redirect_to users_lodging_lodging_calendar(@calendar)
    end
  end
end
