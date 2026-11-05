# frozen_string_literal: true

class GuestStay < ApplicationRecord
  belongs_to :house_season
  belongs_to :host, class_name: 'User'
  belongs_to :guest, class_name: 'User', optional: true
  has_one :lodging, through: :house_season
  has_many :bed_requests, dependent: :restrict_with_error
  attr_reader :token

  before_validation :prepare_invitation, on: :create
  enum :status, { requested: 'requested', approved: 'approved', declined: 'declined', cancelled: 'cancelled' },
    validate: true
  validates :guest_name, :arrival, :departure, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :cars, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :valid_guest_stay
  validate :guest_is_not_roommate
  validate :no_duplicate_guest
  attr_readonly :house_season_id, :host_id, :email, :guest_name, :arrival, :departure
  scope :on_night, ->(night) { approved.where('arrival <= ? AND departure > ?', night, night) }

  def self.for_token(token)
    find_by!(token_digest: OpenSSL::Digest::SHA256.hexdigest(token.to_s))
  end

  def accept!(account)
    with_lock do
      valid = expires_at.future? && accepted_at.nil? && !cancelled? && !declined?
      raise ArgumentError, 'Guest invitation is no longer available' unless valid
      raise ArgumentError, 'Sign in with the invited email address' unless account.email.casecmp?(email)

      update!(guest: account.user, accepted_at: Time.current)
    end
  end

  def transition!(value)
    with_lock do
      update!(status: value)

      bed_requests.where.not(status: 'cancelled').find_each { |request| request.transition!('cancelled') } if
        cancelled? || declined?
    end
  end

  private

  def prepare_invitation
    self.email = email.to_s.strip.downcase
    @token = SecureRandom.urlsafe_base64(32)
    self.token_digest = OpenSSL::Digest::SHA256.hexdigest(@token)
    self.expires_at ||= 7.days.from_now
  end

  def valid_guest_stay
    return unless house_season

    house = house_season.lodging
    if arrival && departure
      valid = departure > arrival && departure - arrival <= 183 && arrival >= house_season.starts_on &&
        departure - 1 <= house_season.ends_on
      errors.add(:base, 'Use occupied nights within this season') unless valid
    end

    return if house.roommates.exists?(user_id: host_id, access_state: 'active', role: Roommate.roles.keys - ['guest'])

    errors.add(:host, 'must be an accepted roommate')
  end

  def guest_is_not_roommate
    return unless house_season

    members = house_season.lodging.roommates.where(access_state: 'active').where.not(role: 'guest').joins(user: :account)
    errors.add(:email, 'belongs to a roommate, who does not owe guest fees') if
      members.exists?(['LOWER(accounts.email) = ?', email.to_s.downcase])
  end

  def no_duplicate_guest
    return unless new_record? && arrival && departure

    duplicate = house_season.lodging.guest_stays.where.not(status: %w[cancelled declined]).where(email: email)
      .where('arrival < ? AND departure > ?', departure, arrival)
    errors.add(:base, 'This guest already has an overlapping stay in this house') if duplicate.exists?
  end
end
