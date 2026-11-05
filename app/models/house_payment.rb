# frozen_string_literal: true

class HousePayment < ApplicationRecord
  belongs_to :house_ledger_entry
  belongs_to :paid_by, class_name: 'User', optional: true
  validate :payer_matches_charge
  belongs_to :recorded_by, class_name: 'Account', optional: true
  validates :amount_cents, numericality: { only_integer: true, greater_than: 0 }
  validates :paid_on, :recorded_by, presence: true, unless: :source_reported?
  validate :within_balance
  attr_readonly :house_ledger_entry_id, :amount_cents, :paid_on, :recorded_by_id, :source_reported, :reference,
    :paid_by_id

  private

  def payer_matches_charge
    return unless paid_by && house_ledger_entry

    entry = house_ledger_entry
    allowed_ids = [entry.user_id, entry.guest_stay&.guest_id].compact
    errors.add(:paid_by, 'must be the charged member or their invited guest') unless allowed_ids.include?(paid_by_id)
  end

  def within_balance
    return unless house_ledger_entry && amount_cents
    return if amount_cents <= house_ledger_entry.outstanding_cents

    errors.add(:amount_cents, 'exceeds the outstanding balance')
  end
end
