# frozen_string_literal: true

module Users
  class LodgingsController < ApplicationController
    before_action :authenticate_account!

    def index
      @lodgings = current_account.user.lodgings
    end

    def show
      @lodging = current_account.user.lodgings.find(params[:id])
    end

    def new
      @lodging = Lodging.new
    end

    def edit
      @lodging = current_account.user.lodgings.find(params[:id])
      authorize @lodging, :update?
    end

    def create
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
        :country, :status, :season_start, :season_end, :max_cars])
    end

    def update_lodging_params
      params.expect(lodging: [:title, :description, :max_guests, :status, :season_start, :season_end, :max_cars])
    end
  end
end
