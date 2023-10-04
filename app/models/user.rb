# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :validatable, :confirmable, :lockable, :timeoutable,
         :trackable, :omniauthable

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.full_name = auth.info.name # assuming the user model has a name
      user.avatar_url = auth.info.image # assuming the user model has an image
      user.skip_confirmation! # User is already verified with Google.
    end
  end
end
