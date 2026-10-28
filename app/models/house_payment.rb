# frozen_string_literal: true

class HousePayment < ApplicationRecord
  belongs_to :house_ledger_entry
  belongs_to :recorded_by, class_name: 'Account', optional: true
  validates :amount_cents, numericality: { only_integer: true, greater_than: 0 }
  validates :paid_on, :recorded_by, presence: true, unless: :source_reported?
  validate :within_balance
  attr_readonly :house_ledger_entry_id, :amount_cents, :paid_on, :recorded_by_id, :source_reported, :reference

  private

  def within_balance
    return unless house_ledger_entry && amount_cents
    return if amount_cents <= house_ledger_entry.outstanding_cents

    errors.add(:amount_cents, 'exceeds the outstanding balance')
  end
end
