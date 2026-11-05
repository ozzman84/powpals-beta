# frozen_string_literal: true

module Users
  class BedsController < ApplicationController
    before_action :authenticate_account!

    def update
      house = current_account.user.lodgings.find(params[:lodging_id])
      authorize house, :manage_rooms?
      bed = house.rooms.find(params[:room_id]).beds.find(params[:id])
      success = bed.update(params.expect(bed: [:capacity, :size, :style, :label, :temporary, :notes]))
      redirect_to users_lodging_rooms_path(house), alert: (success ? nil : bed.errors.full_messages.to_sentence)
    end
  end
end
