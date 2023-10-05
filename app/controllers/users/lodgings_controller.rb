# frozen_string_literal: true

module Users
  class LodgingsController < ApplicationController
    # before_action :find_lodging, only: [:show, :destroy, :update, :edit]

    def index
      @lodgings = current_user.lodgings
    end

    def show
      @lodging = current_user.lodgings.find(params[:id])
    end

    def edit
      @lodging = current_user.lodgings.find(params[:id])
    end

    def new
      @lodging = Lodging.new
    end

    def update
      @lodging = current_user.lodgings.find(params[:id])

      if @lodging.update(update_lodging_params)
        redirect_to users_lodging_path(@lodging)
      else
        flash.now[:errors] = @lodging.errors.full_messages
        render :edit
      end
    end

    def create
      @lodging = current_user.lodgings.new(create_lodging_params)

      if @lodging.save && create_lodging_roommate
        redirect_to users_lodging_path(@lodging)
      else
        flash.now[:errors] = @lodging.errors.full_messages
        render :new
      end
    end

    def destroy
      @lodging = current_user.lodgings.find(params[:id])
      @lodging.update(status: :archived)
      redirect_to users_lodgings_path
    end

    private

    def create_lodging_params
      params.require(:lodging).permit(:title, :description, :max_guests, :street, :city, :state, :zip_code, :country)
    end

    def update_lodging_params
      params.require(:lodging).permit(:title, :description, :max_guests)
    end

    def create_lodging_roommate
      Roommate.create(user_id: current_user.id, lodging_id: @lodging.id)
    end

    # def find_lodging
    #   @lodging = current_user.lodgings.find(params[:id])
    # end
  end
end
