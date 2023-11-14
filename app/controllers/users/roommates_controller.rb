# frozen_string_literal: true

module Users
  class RoommatesController < ApplicationController
    before_action :authenticate_account!

    def create
      @lodging = current_account.user.lodgings.find(params[:lodging_id])

      if @lodging.roommates.create(roommate_params)
        flash[:success]
      else
        flash.now[:errors] = @lodging.errors.full_messages
      end
    end

    private

    def roommate_params
      params.permit(:lodging_id, :role, :user_id)
    end
  end
end
