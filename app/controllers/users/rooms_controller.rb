# frozen_string_literal: true

module Users
  class RoomsController < ApplicationController
    def index
      @lodging = current_user.lodgings.find(params[:lodging_id])
      @rooms = @lodging.rooms.all
    end

    def create
      @lodging = current_user.lodgings.find(params[:lodging_id])
      @room = @lodging.rooms.new(room_params)

      flash[:errors] = @room.errors.full_messages unless @room.save

      redirect_to users_lodging_rooms_path(@lodging)
    end

    def destroy
      @lodging = current_user.lodgings.find(params[:lodging_id])
      @room = @lodging.rooms.find(params[:id])
      @room.destroy
      redirect_to users_lodging_rooms_path(@lodging)
    end

    private

    def room_params
      params.require(:room).permit(:room_type, :name, beds_attributes: %i[size style])
    end
  end
end
