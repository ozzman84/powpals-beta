# frozen_string_literal: true

module Users
  class RoommatesController < ApplicationController
    before_action :authenticate_account!

    def create
      lodging = current_account.user.lodgings.find(params[:lodging_id])
      authorize lodging, :manage_roommates?
      values = params.expect(roommate: [:email, :user_id, :role, :house_season_id]).to_h
      email = values['email'].presence || User.find(values['user_id']).account.email
      role = values['role'].presence || 'roommate'
      return head :unprocessable_entity unless (Roommate.roles.keys - ['guest']).include?(role)

      season = lodging.house_seasons.find(values['house_season_id']) if values['house_season_id'].present?
      invitation = lodging.house_invitations.create!(email: email, role: role, invited_by: current_account,
        house_season: season)
      redirect_to users_lodging_path(lodging),
        notice: "Invitation created. Share privately: #{house_invitation_url(token: invitation.token)}"
    rescue ActiveRecord::RecordInvalid => e
      redirect_to users_lodging_path(lodging), alert: e.record.errors.full_messages.to_sentence
    end

    def destroy
      lodging = current_account.user.lodgings.find(params[:lodging_id])
      authorize lodging, :manage_roommates?
      lodging.house_invitations.find(params[:id]).update!(revoked_at: Time.current)
      redirect_to users_lodging_path(lodging), notice: 'Invitation revoked.', status: :see_other
    end
  end
end
