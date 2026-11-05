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
  validate :owned_pass_terms_do_not_overlap

  devise :database_authenticatable, :registerable, :recoverable,
    :rememberable, :validatable, :confirmable, :lockable, :timeoutable,
    :trackable, :omniauthable, omniauth_providers: [:google]

  def self.from_omniauth(auth)
    validate_google_identity!(auth)
    transaction do
      account = find_by(provider: auth.provider, uid: auth.uid) || create_google_account!(auth)
      account.create_user!(google_profile(auth)) unless account.user
      account.populate_google_avatar!(auth.info.image)
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

  def owned_pass_terms_do_not_overlap
    terms = account_season_passes.reject do |owned|
      owned.marked_for_destruction? || owned.season_unknown? || !owned.starts_on || !owned.expires_on
    end
    overlap = terms.group_by(&:season_pass_id).values.any? do |group|
      group.combination(2).any? do |left, right|
        left.starts_on <= right.expires_on && right.starts_on <= left.expires_on
      end
    end
    errors.add(:base, 'Owned pass seasons cannot overlap for the same pass type') if overlap
  end

  def populate_google_avatar!(image)
    return unless active_for_authentication? && image.present? && user.avatar_url.blank?

    # Provider metadata must not make login fail on unrelated legacy profile validations.
    user.update_columns(avatar_url: image, updated_at: Time.current) # rubocop:disable Rails/SkipsModelValidations
  end

  def active_account_season_passes
    account_season_passes.current
  end

  def active_season_passes
    SeasonPass.where(id: active_account_season_passes.select(:season_pass_id))
  end

  def any_season_passes?
    active_account_season_passes.exists?
  end

  def all_pass_resorts
    Resort.where(id: active_season_passes.joins(:resorts).select('resorts.id'))
  end

  def pass_or_all_resorts
    any_season_passes? ? all_pass_resorts : Resort.all
  end

  def ski_days_within_range(start_date, end_date)
    AccountSkiDay.where(start_date: start_date..end_date)
  end

  def order_resorts_by_ski_day_counts(account_ski_days)
    days = AccountSkiDay.arel_table
    counts = account_ski_days.reselect(:resort_id, days[:id].count.as('skier_count'))
      .group(:resort_id).arel.as('planned_days')
    mountains = Resort.arel_table
    joins = mountains.join(counts, Arel::Nodes::OuterJoin).on(counts[:resort_id].eq(mountains[:id])).join_sources
    pass_or_all_resorts.joins(joins).order(counts[:skier_count].desc.nulls_last, mountains[:name].asc)
  end

  def resort_data_for_multiple_days(number_of_days = 10)
    account_ski_days = ski_days_within_range(Date.current, Date.current + number_of_days - 1)
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
