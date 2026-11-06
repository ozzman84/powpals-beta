# frozen_string_literal: true

module Users
  class LodgingsController < ApplicationController
    before_action :authenticate_account!

    def index
      @lodgings = current_account.user.lodgings
    end

    def show
      @lodging = current_account.user.lodgings.find(params[:id])
      season = @lodging.house_seasons.find_by(starts_on: @lodging.season_start, ends_on: @lodging.season_end)
      @roommate_season_details = season ? season.house_season_memberships.index_by(&:roommate_id) : {}
      @availability_date = Date.current
      @rooms = @lodging.rooms.includes(:beds).order(:name)
      beds = @rooms.flat_map(&:beds)
      requests = BedRequest.where(bed_id: beds.map(&:id), status: %w[confirmed requested])
        .overlapping(@availability_date, @availability_date + 1).includes(:user, guest_stay: :guest).group_by(&:bed_id)
      @bed_availability = beds.to_h { |bed| [bed.id, BedAvailability.new(bed, requests.fetch(bed.id, []))] }
    end

    def new
      return head :forbidden unless current_account.user.roommates.exists?(role: %w[admin lease_holder])

      @lodging = Lodging.new
    end

    def edit
      @lodging = current_account.user.lodgings.find(params[:id])
      authorize @lodging, :update?
    end

    def create
      return head :forbidden unless current_account.user.roommates.exists?(role: %w[admin lease_holder])

      @lodging = Lodging.new(create_lodging_params)

      saved = Lodging.transaction do
        @lodging.save!
        @lodging.roommates.create!(user: current_account.user, role: :lease_holder)
        true
      rescue ActiveRecord::RecordInvalid
        raise ActiveRecord::Rollback
      end

      if saved
        redirect_to users_lodging_path(@lodging)
      else
        flash.now[:errors] = @lodging.errors.full_messages
        render :new, status: :unprocessable_entity
      end
    end

    def update
      @lodging = current_account.user.lodgings.find(params[:id])

      authorize @lodging

      if @lodging.update(update_lodging_params)
        redirect_to users_lodging_path(@lodging)
      else
        flash.now[:errors] = @lodging.errors.full_messages
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @lodging = current_account.user.lodgings.find(params[:id])
      authorize @lodging
      @lodging.update!(status: :archived)
      redirect_to users_lodgings_path, status: :see_other
    end

    private

    def create_lodging_params
      params.expect(lodging: [:title, :description, :max_guests, :street, :address2, :city, :state, :zip_code,
        :country, :status, :season_start, :season_end, :max_cars, :layout_reference_url])
    end

    def update_lodging_params
      params.expect(lodging: [:title, :description, :max_guests, :status, :season_start, :season_end, :max_cars,
        :layout_reference_url])
    end
  end
end
