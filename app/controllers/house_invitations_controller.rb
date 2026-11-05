# frozen_string_literal: true

class HouseInvitationsController < ApplicationController
  before_action :authenticate_account!
  before_action :load_invitation

  def show
    return head :gone unless @invitation.available?

    head :forbidden unless current_account.email.casecmp?(@invitation.email)
  end

  def update
    @invitation.accept!(current_account)
    redirect_to users_lodging_path(@invitation.lodging), notice: 'House invitation accepted.'
  rescue ArgumentError => e
    redirect_to user_path, alert: e.message
  end

  private

  def load_invitation
    @invitation = HouseInvitation.for_token(params[:token])
  end
end
