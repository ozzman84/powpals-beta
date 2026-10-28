# frozen_string_literal: true

module Users
  class CalendarsController < ApplicationController
    before_action :authenticate_account!
    before_action :load_lodging

    def show
      @lodging_calendars = @lodging.calendars.grouped_by_date_with_avatars(calendar_start)
    end

    def my_calendar
      @calendars = current_account.user.calendars.where(lodging: @lodging)
    end

    def create
      authorize @lodging, :stay?
      @calendar = current_account.user.calendars.new(calendar_params.merge(lodging: @lodging))
      finish_change(@lodging.with_lock { @calendar.save })
    end

    def update
      authorize @lodging, :stay?
      @calendar = current_account.user.calendars.where(lodging: @lodging).find(params[:id])
      finish_change(@lodging.with_lock { @calendar.update(calendar_params.except(:date)) })
    end

    def destroy
      authorize @lodging, :stay?
      @calendar = current_account.user.calendars.where(lodging: @lodging).find(params[:id])
      finish_change(@calendar.destroy)
    end

    private

    def load_lodging
      @lodging = current_account.user.lodgings.find(params[:lodging_id])
      @current_date = calendar_start
    end

    def calendar_start
      Date.iso8601((params[:start_date] || params.dig(:calendar, :start_date)).to_s)
    rescue Date::Error
      Date.current
    end

    def calendar_params
      params.expect(calendar: [:date, :status, :guest_count, :cars])
    end

    def finish_change(success)
      redirect_to my_calendar_users_lodging_calendars_path(@lodging, start_date: calendar_start),
        alert: (success ? nil : @calendar.errors.full_messages.to_sentence)
    end
  end
end
