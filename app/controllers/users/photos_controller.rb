class Users::PhotosController < ApplicationController
  before_action :authenticate_user!

  def index
    @lodging = current_user.lodgings.find(params[:lodging_id])
    @photos = @lodging.photos
  end

  def create
    @lodging = current_user.lodgings.find(params[:lodging_id])
    @photo = @lodging.photos.new(photo_params)

    flash[:errors] = @photo.errors.full_messages unless @photo.save
    
    redirect_to users_lodging_photos_path(@lodging)
  end

  def destroy
    
  end

  private

  def photo_params
    params.require(:photo).permit(:caption, :photo)
  end
end
