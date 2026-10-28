# frozen_string_literal: true

class HouseSeason < ApplicationRecord
  belongs_to :lodging
  has_many :house_ledger_entries, dependent: :restrict_with_error
  has_many :house_sheet_cells, dependent: :restrict_with_error

  enum :policy_status, { draft: 'draft', reference: 'reference', confirmed: 'confirmed' }, validate: true
  enum :dog_fee_basis, { unconfirmed: 'unconfirmed', per_night: 'per_night', per_stay: 'per_stay' }, validate: true
  validates :name, :starts_on, :ends_on, presence: true
  validates :starts_on, uniqueness: { scope: %i[lodging_id ends_on] }
  validates :monthly_rent_cents, :dog_fee_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 },
    allow_nil: true
  validates :participant_count, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :free_nights, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :date_order
  validate :valid_rates

  def months
    return [] unless starts_on && ends_on && ends_on >= starts_on

    month = starts_on.beginning_of_month
    result = []
    while month <= ends_on
      result << month
      month = month.next_month
    end
    result
  end

  def monthly_summary(month)
    entries = house_ledger_entries.where(month_on: month).includes(:house_payments)
    fees = entries.select(&:guest_fee?)
    expenses = entries.select(&:expense?)
    { fees: fees.sum(&:amount_cents), received: fees.sum(&:paid_cents),
      expenses: expenses.sum(&:amount_cents), reimbursed: expenses.sum(&:paid_cents),
      outstanding: fees.sum(&:outstanding_cents) }
  end

  private

  def date_order
    errors.add(:ends_on, 'must follow the start date') if starts_on && ends_on && ends_on < starts_on
  end

  def valid_rates
    valid = guest_rates.is_a?(Hash) && guest_rates.all? do |day, amount|
      Date::DAYNAMES.include?(day) && amount.is_a?(Integer) && amount >= 0
    end
    errors.add(:guest_rates, 'must contain weekday names and nonnegative integer cents') unless valid
    return unless confirmed?
    return if valid && guest_rates.keys.sort == Date::DAYNAMES.sort

    errors.add(:guest_rates, 'need all seven days before confirming')
  end
end
