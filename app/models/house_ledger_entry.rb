# frozen_string_literal: true

class HouseLedgerEntry < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :house_season
  belongs_to :recorded_by, class_name: 'Account', optional: true
  has_many :house_payments, dependent: :restrict_with_error
  enum :kind, { guest_fee: 'guest_fee', expense: 'expense', rent: 'rent', deposit: 'deposit',
    shared_charge: 'shared_charge' }, validate: true
  validates :kind, :description, :month_on, presence: true
  validates :amount_cents, numericality: { only_integer: true, greater_than: 0 }
  validates :source_key, uniqueness: { scope: :house_season_id }, allow_nil: true
  validate :within_season
  validate :member_ownership
  scope :rent_and_deposits, -> { where(kind: %w[rent deposit]) }
  scope :personal_charges, -> { where.not(kind: 'expense') }

  attr_readonly :house_season_id, :kind, :description, :month_on, :amount_cents, :source_key, :source_data

  def paid_cents
    house_payments.to_a.sum(&:amount_cents)
  end

  def outstanding_cents
    amount_cents - paid_cents
  end

  def record_payment!(attributes)
    with_lock do
      house_payments.reload
      house_payments.create!(attributes)
    end
  end

  private

  def member_ownership
    if new_record? && !expense? && source_key.blank? && user.nil?
      errors.add(:user,
        'must be selected for a personal charge')
    end

    return unless user && house_season
    return if house_season.lodging.roommates.exists?(user_id: user.id)

    errors.add(:user, 'must belong to this house')
  end

  def within_season
    return unless house_season && month_on
    return if house_season.months.include?(month_on)

    errors.add(:month_on, 'must be the first day of a month in this season')
  end
end
