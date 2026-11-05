# frozen_string_literal: true

class HouseInvitation < ApplicationRecord
  belongs_to :lodging
  belongs_to :invited_by, class_name: 'Account'
  attr_reader :token

  before_validation :prepare_invitation, on: :create
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, inclusion: { in: Roommate.roles.keys - ['guest'] }
  validates :token_digest, :expires_at, presence: true

  def self.for_token(token)
    find_by!(token_digest: OpenSSL::Digest::SHA256.hexdigest(token.to_s))
  end

  def available?
    accepted_at.nil? && revoked_at.nil? && expires_at.future?
  end

  def accept!(account)
    with_lock do
      raise ArgumentError, 'Invitation is expired, revoked or already accepted' unless available?
      raise ArgumentError, 'Sign in with the invited email address' unless account.email.casecmp?(email)

      lodging.roommates.find_or_create_by!(user: account.user) { |member| member.role = role }
      update!(accepted_at: Time.current)
    end
  end

  private

  def prepare_invitation
    self.email = email.to_s.strip.downcase
    @token = SecureRandom.urlsafe_base64(32)
    self.token_digest = OpenSSL::Digest::SHA256.hexdigest(@token)
    self.expires_at ||= 7.days.from_now
  end
end
