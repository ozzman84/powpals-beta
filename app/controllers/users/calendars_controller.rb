class Users::CalendarsController < ApplicationController
  before_action :authenticate_account!

  def show
  end

  def my_calendar
    @calendar = current_account.user.calendars.where(lodging_id: params[:lodging_id])
  end

  def create
    puts params
    @calendar = current_account.user.calendars.new(create_calendar_params)

    if @calendar.save
      redirect_to my_calendar_users_lodging_calendars_path
    else
      puts @calendar.errors.full_messages
      flash.now[:errors] = @calendar.errors.full_messages
    end
  end

  private

  def create_calendar_params
    params.require(:calendar).permit(:date, :lodging_id, :status)
  end
end
