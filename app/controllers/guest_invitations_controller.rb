# frozen_string_literal: true

class GuestInvitationsController < ApplicationController
  before_action :authenticate_account!

  def show
    @stay = GuestStay.for_token(params[:token])
    return head :forbidden unless current_account.email.casecmp?(@stay.email)

    head :gone if @stay.expires_at.past? || @stay.cancelled? || @stay.declined? || @stay.accepted_at
  end

  def update
    stay = GuestStay.for_token(params[:token])
    stay.accept!(current_account)
    redirect_to guest_visit_path(stay), notice: 'Guest invitation accepted. Check the stay approval status below.'
  rescue ArgumentError, ActiveRecord::RecordInvalid => e
    redirect_to user_path, alert: e.message
  end
end
