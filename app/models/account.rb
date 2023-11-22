# frozen_string_literal: true

class Account < ApplicationRecord
  has_one :user
  has_many :account_season_passes
  has_many :season_passes, through: :account_season_passes
  accepts_nested_attributes_for :account_season_passes
  accepts_nested_attributes_for :user

  validates_uniqueness_of :email

  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :validatable, :confirmable, :lockable, :timeoutable,
         :trackable, :omniauthable

  def any_season_passes?
    season_passes.any?
  end

  def self.from_omniauth(auth)
    account = get_account(auth)

    User.where(first_name: auth.info.first_name, last_name: auth.info.last_name).first_or_create(
      first_name: auth.info.first_name,
      last_name: auth.info.last_name,
      full_name: auth.info.name,
      avatar_url: auth.info.image,
      account_id: account.id
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
