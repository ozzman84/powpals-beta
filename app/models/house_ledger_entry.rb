# frozen_string_literal: true

class HouseLedgerEntry < ApplicationRecord
  belongs_to :house_season
  belongs_to :recorded_by, class_name: 'Account', optional: true
  has_many :house_payments, dependent: :restrict_with_error
  enum :kind, { guest_fee: 'guest_fee', expense: 'expense' }, validate: true
  validates :kind, :description, :month_on, presence: true
  validates :amount_cents, numericality: { only_integer: true, greater_than: 0 }
  validates :source_key, uniqueness: { scope: :house_season_id }, allow_nil: true
  validate :within_season
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

  def within_season
    return unless house_season && month_on
    return if house_season.months.include?(month_on)

    errors.add(:month_on, 'must be the first day of a month in this season')
  end
end
