# frozen_string_literal: true

module Users
  class GuestStaysController < ApplicationController
    before_action :authenticate_account!
    before_action :load_house

    def index
      @seasons = @lodging.house_seasons.order(starts_on: :desc)
      @stays = @lodging.guest_stays.includes(:host, :guest).order(:arrival)
    end

    def create
      authorize @lodging, :stay?
      values = params.expect(guest_stay: [:house_season_id, :guest_name, :email, :arrival, :departure, :cars]).to_h
      season = @lodging.house_seasons.find(values.delete('house_season_id'))
      stay = @lodging.with_lock { season.guest_stays.create!(values.merge(host: current_account.user)) }
      redirect_to users_lodging_guest_stays_path(@lodging),
        notice: "Guest requested. Share privately: #{guest_invitation_url(token: stay.token)}"
    rescue ActiveRecord::RecordInvalid => e
      redirect_to users_lodging_guest_stays_path(@lodging), alert: e.record.errors.full_messages.to_sentence
    end

    def update
      stay = @lodging.guest_stays.find(params[:id])
      status = params.expect(guest_stay: [:status])[:status]
      manager = policy(@lodging).manage_roommates?
      allowed = manager || (stay.host_id == current_account.user.id && status == 'cancelled')
      raise Pundit::NotAuthorizedError unless allowed

      stay.transition!(status)
      redirect_to users_lodging_guest_stays_path(@lodging), notice: 'Guest stay updated.'
    rescue ActiveRecord::RecordInvalid => e
      redirect_to users_lodging_guest_stays_path(@lodging), alert: e.record.errors.full_messages.to_sentence
    end

    private

    def load_house
      @lodging = current_account.user.lodgings.find(params[:lodging_id])
      authorize @lodging, :view_operations?
    end
  end
end
