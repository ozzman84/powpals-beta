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

    def update
      lodging = current_account.user.lodgings.find(params[:lodging_id])
      authorize lodging, :manage_roommates?
      member = lodging.roommates.find(params[:id])
      values = params.expect(roommate: [:role, :access_state])
      lodging.with_lock do
        managers = lodging.roommates.where(access_state: 'active',
          role: %w[admin lease_holder]).where.not(id: member.id)
        leaving = values[:access_state] == 'revoked' || (values[:role] && %w[admin
          lease_holder].exclude?(values[:role]))

        if member.user_id == current_account.user.id && leaving && !managers.exists?
          member.errors.add(:base, 'Keep at least one house manager')
          raise ActiveRecord::RecordInvalid, member
        end

        member.update!(values)
      end
      redirect_to users_lodging_house_members_path(lodging), notice: 'House access updated.'
    rescue ActiveRecord::RecordInvalid => e
      redirect_to users_lodging_house_members_path(lodging), alert: e.record.errors.full_messages.to_sentence
    end

    def destroy
      lodging = current_account.user.lodgings.find(params[:lodging_id])
      authorize lodging, :manage_roommates?
      lodging.house_invitations.find(params[:id]).update!(revoked_at: Time.current)
      redirect_to users_lodging_path(lodging), notice: 'Invitation revoked.', status: :see_other
    end
  end
end
