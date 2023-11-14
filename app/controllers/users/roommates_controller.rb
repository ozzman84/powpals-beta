# frozen_string_literal: true

module Users
  # brakeman-disable-all
  class RoommatesController < ApplicationController
    before_action :authenticate_account!

    def create
      @lodging = current_account.user.lodgings.find(params[:lodging_id])
      roommate = @lodging.roommates.new(roommate_params)
      if roommate.save
        flash[:success]
      else
        flash.now[:errors] = roommate.errors.full_messages
      end
    end

    private

    # brakeman-disable-next-line MassAssignment
    def roommate_params
      params.require(:roommate).permit(:lodging_id, :role, :user_id)
    end
  end
end
