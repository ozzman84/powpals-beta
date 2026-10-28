# frozen_string_literal: true

module Users
  class RoommatesController < ApplicationController
    before_action :authenticate_account!

    def create
      lodging = current_account.user.lodgings.find(params[:lodging_id])
      authorize lodging, :manage_roommates?
      attributes = params.expect(roommate: [:user_id])
      role = params.dig(:roommate, :role).presence || 'roommate'
      return head :unprocessable_entity unless Roommate.roles.key?(role)

      roommate = lodging.roommates.new(attributes)
      roommate.role = role
      if roommate.save
        redirect_to users_lodging_path(lodging), notice: 'Roommate added.'
      else
        redirect_to users_lodging_path(lodging), alert: roommate.errors.full_messages.to_sentence
      end
    end
  end
end
