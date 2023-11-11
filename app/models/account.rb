# frozen_string_literal: true

class Account < ApplicationRecord
  has_one :user
  has_many :account_season_passes
  has_many :season_passes, through: :account_season_passes

  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :validatable, :confirmable, :lockable, :timeoutable,
         :trackable, :omniauthable

  def self.from_omniauth(auth)
    User.create(
      first_name: auth.info.first_name,
      last_name: auth.info.last_name,
      full_name: auth.info.name,
      avatar_url: auth.info.image,
      account: get_account(auth)
    ).account
  end

  def self.get_account(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |account|
      set_account_attributes(account, auth)
      account.skip_confirmation! # User is already verified with Google.
    end
  end

  def self.set_account_attributes(account, auth)
    account.email = auth.info.email
    account.password = Devise.friendly_token[0, 20]
  end
end
