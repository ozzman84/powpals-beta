# frozen_string_literal: true

module Users
  class BedRequestsController < ApplicationController
    before_action :authenticate_account!
    before_action :load_house

    def index
      @beds = Bed.where(room_id: @lodging.rooms.select(:id)).includes(:room)
      @requests = BedRequest.where(bed_id: @beds.select(:id)).includes(:user, bed: :room).order(:arrival)
    end

    def create
      authorize @lodging, :stay?
      values = params.expect(bed_request: [:bed_id, :arrival, :departure, :spaces]).to_h
      bed = Bed.where(room_id: @lodging.rooms.select(:id)).find(values.delete('bed_id'))
      bed.bed_requests.create!(values.merge(user: current_account.user))
      redirect_to users_lodging_bed_requests_path(@lodging),
        notice: 'Bed requested. This is not a confirmed assignment.'
    rescue ActiveRecord::RecordInvalid => e
      redirect_to users_lodging_bed_requests_path(@lodging), alert: e.record.errors.full_messages.to_sentence
    end

    def update
      request = BedRequest.where(bed_id: Bed.where(room_id: @lodging.rooms.select(:id)).select(:id)).find(params[:id])
      status = params.expect(bed_request: [:status])[:status]
      manager = policy(@lodging).manage_rooms?
      allowed = manager || (request.user_id == current_account.user.id && status == 'cancelled')
      raise Pundit::NotAuthorizedError unless allowed

      request.transition!(status)
      redirect_to users_lodging_bed_requests_path(@lodging), notice: 'Bed request updated.'
    rescue ActiveRecord::RecordInvalid => e
      redirect_to users_lodging_bed_requests_path(@lodging), alert: e.record.errors.full_messages.to_sentence
    end

    private

    def load_house
      @lodging = current_account.user.lodgings.find(params[:lodging_id])
      authorize @lodging, :view_operations?
    end
  end
end
