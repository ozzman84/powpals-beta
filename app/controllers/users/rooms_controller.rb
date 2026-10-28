# frozen_string_literal: true

module Users
  class RoomsController < ApplicationController
    before_action :authenticate_account!

    def index
      @lodging = current_account.user.lodgings.find(params[:lodging_id])
      @rooms = @lodging.rooms.all
    end

    def create
      @lodging = current_account.user.lodgings.find(params[:lodging_id])
      authorize @lodging, :manage_rooms?
      @room = @lodging.rooms.new(room_params)

      flash[:errors] = @room.errors.full_messages unless @room.save

      redirect_to users_lodging_rooms_path(@lodging)
    end

    def destroy
      @lodging = current_account.user.lodgings.find(params[:lodging_id])
      authorize @lodging, :manage_rooms?
      @room = @lodging.rooms.find(params[:id])
      @room.destroy
      redirect_to users_lodging_rooms_path(@lodging), status: :see_other
    end

    private

    def room_params
      params.expect(room: [:room_type, :name, { beds_attributes: [%i[size style]] }])
    end
  end
end
