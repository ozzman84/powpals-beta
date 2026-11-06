# frozen_string_literal: true

module Users
  class CalendarsController < ApplicationController
    before_action :authenticate_account!
    before_action :load_lodging

    def show
      @lodging_calendars = HouseAttendance.new(@lodging.calendars,
        lodging: @lodging).call(Calendar.build_dates(calendar_start))
    end

    def my_calendar
      @calendars = current_account.user.calendars.where(lodging: @lodging)
      @month_stays = @calendars.where(date: @current_date.all_month).order(:date)
      dates = Calendar.build_dates(@current_date)
      @guest_counts = Hash.new(0)
      @calendars.staying.where(date: dates).pluck(:date, :guest_count).each do |date, count|
        @guest_counts[date] += count
      end
      @lodging.guest_stays.approved.where(host: current_account.user)
        .where('arrival <= ? AND departure > ?', dates.last, dates.first)
        .pluck(:arrival, :departure).each do |arrival, departure|
        ([arrival, dates.first].max...[departure, dates.last + 1].min).each { |date| @guest_counts[date] += 1 }
      end
    end

    def create
      authorize @lodging, :stay?
      return create_range if params.dig(:calendar, :arrival).present?

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

    def create_range
      dates = params.expect(calendar: [:arrival, :checkout]).to_h.symbolize_keys
      result = StayRange.new(@lodging, current_account.user).call(**dates,
**calendar_params.except(:date).to_h.symbolize_keys)
      flash[:warning] = result.warnings.join(' ') if result.warnings.any?
      redirect_to my_calendar_users_lodging_calendars_path(@lodging, start_date: result.arrival),
        notice: "Added #{result.created} nights; #{result.unchanged} existing days kept unchanged."
    rescue ArgumentError, ActiveRecord::RecordInvalid => e
      redirect_to my_calendar_users_lodging_calendars_path(@lodging, start_date: calendar_start), alert: e.message
    end

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
      if success && !@calendar.destroyed? && @calendar.capacity_warnings.any?
        flash[:warning] =
          @calendar.capacity_warnings.join(' ')
      end

      redirect_to my_calendar_users_lodging_calendars_path(@lodging, start_date: calendar_start),
        alert: (success ? nil : @calendar.errors.full_messages.to_sentence)
    end
  end
end
