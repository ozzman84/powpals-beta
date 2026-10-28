# frozen_string_literal: true

class Account < ApplicationRecord
  has_one :user, dependent: :destroy
  has_many :account_season_passes, dependent: :destroy
  has_many :season_passes, through: :account_season_passes
  has_many :account_ski_days, dependent: :destroy
  has_many :resorts, through: :season_passes
  has_many :ski_day_resorts, through: :account_ski_days, source: :resort
  accepts_nested_attributes_for :account_season_passes
  accepts_nested_attributes_for :user

  validates :email, uniqueness: true

  devise :database_authenticatable, :registerable, :recoverable,
    :rememberable, :validatable, :confirmable, :lockable, :timeoutable,
    :trackable, :omniauthable, omniauth_providers: [:google]

  def self.from_omniauth(auth)
    validate_google_identity!(auth)
    transaction do
      account = find_by(provider: auth.provider, uid: auth.uid) || create_google_account!(auth)
      account.create_user!(google_profile(auth)) unless account.user
      account
    end
  end

  def self.validate_google_identity!(auth)
    verified = auth.dig('extra', 'raw_info', 'email_verified')
    return if auth.provider == 'google' && auth.uid.present? && auth.info.email.present? && [true,
      'true'].include?(verified)

    raise ArgumentError, 'A verified Google identity is required'
  end

  def self.create_google_account!(auth)
    account = new(provider: auth.provider, uid: auth.uid, email: auth.info.email.strip.downcase,
      password: Devise.friendly_token(20))
    account.skip_confirmation!
    account.save!
    account
  end

  def self.google_profile(auth)
    {
      first_name: auth.info.first_name.presence || 'Skier',
      last_name: auth.info.last_name.presence || 'Member',
      full_name: auth.info.name,
      avatar_url: auth.info.image, ride_type: :ski, level: :beginner
    }
  end

  def any_season_passes?
    season_passes.any?
  end

  def all_pass_resorts
    resorts.distinct
  end

  def pass_or_all_resorts
    any_season_passes? ? resorts.includes(:account_ski_days) : Resort.all
  end

  def ski_days_within_range(start_date, end_date)
    AccountSkiDay.where(start_date: start_date..end_date)
  end

  def order_resorts_by_ski_day_counts(account_ski_days)
    pass_or_all_resorts.joins(:account_ski_days)
                       .merge(account_ski_days)
                       .group('resorts.id')
                       .order('COUNT(account_ski_days.id) DESC')
  end

  def resort_data_for_multiple_days(number_of_days = 10)
    account_ski_days = ski_days_within_range(Date.current, number_of_days.days.from_now)
    ordered_resorts = account_ski_days.empty? ? pass_or_all_resorts : order_resorts_by_ski_day_counts(account_ski_days)

    aggregate_resort_data(ordered_resorts.limit(20))
  end

  def aggregate_resort_data(resorts)
    resorts.each_with_object({}) do |resort, result|
      result[resort.name] = {
        next_10_day_skier_count: resort.next_10_day_skier_count.values
      }
    end
  end
end
