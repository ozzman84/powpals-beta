# frozen_string_literal: true

class Account < ApplicationRecord
  has_one :user
  has_many :account_season_passes
  has_many :season_passes, through: :account_season_passes
  has_many :account_ski_days
  has_many :resorts, through: :season_passes
  has_many :ski_day_resorts, through: :account_ski_days, source: :resort
  accepts_nested_attributes_for :account_season_passes
  accepts_nested_attributes_for :user

  validates_uniqueness_of :email

  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :validatable, :confirmable, :lockable, :timeoutable,
         :trackable, :omniauthable, omniauth_providers: [:google]

  def any_season_passes?
    season_passes.any?
  end

  def all_pass_resorts
    resorts.distinct
  end

  def pass_or_all_resorts
    any_season_passes? ? resorts : Resort.all
  end

  def order_resorts_by_ski_days(n)
    pass_or_all_resorts.joins(:account_ski_days)
                       .merge(AccountSkiDay.where(start_date: Date.today..(Date.today + n.days)))
                       .group('resorts.id')
                       .order('COUNT(account_ski_days.id) DESC')
  end

  def resort_data_for_multiple_days(number_of_days = 10)
    resorts = order_resorts_by_ski_days(number_of_days)

    resorts.each_with_object({}) do |resort, result|
      result[resort.name] = {
        next_10_day_skier_count: resort.next_10_day_skier_count.values
      }
    end
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
