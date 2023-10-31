class Account < ApplicationRecord
  has_one :user

  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :validatable, :confirmable, :lockable, :timeoutable,
         :trackable, :omniauthable

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |account|
      account.user = account.user || User.find_or_create_by(first_name: auth.info.first_name, last_name: auth.info.last_name)
      set_user_attributes(account.user, account, auth)
      account.skip_confirmation! # User is already verified with Google.
    end
  end

  def self.set_user_attributes(user, account, auth)
    account.email = auth.info.email
    account.password = Devise.friendly_token[0, 20]
    user.full_name = auth.info.name
    user.avatar_url = auth.info.image
  end
end
