# frozen_string_literal: true

class AccountSeasonPass < ApplicationRecord
  belongs_to :account
  belongs_to :season_pass
  validates :starts_on, :expires_on, :season_label, presence: true, unless: :season_unknown?
  validate :valid_season_dates
  scope :current, lambda {
    where(season_unknown: false).where('starts_on <= ? AND expires_on >= ?', Date.current, Date.current)
  }

  def current?
    !season_unknown? && starts_on && expires_on && (starts_on..expires_on).cover?(Date.current)
  end

  def status_label
    return 'Season unknown — inactive' if season_unknown?
    return 'Expired' if expires_on && expires_on < Date.current
    return 'Upcoming' if starts_on && starts_on > Date.current

    'Current'
  end

  private

  def valid_season_dates
    return if season_unknown? && starts_on.nil? && expires_on.nil?

    if season_unknown?
      errors.add(:base, 'Unknown-season records cannot have dates')
      return
    end

    return unless starts_on && expires_on

    errors.add(:expires_on, 'must follow the start date') if expires_on < starts_on
    siblings = self.class.where(account_id: account_id, season_pass_id: season_pass_id, season_unknown: false)
      .where.not(id: id).where('starts_on <= ? AND expires_on >= ?', expires_on, starts_on)
    errors.add(:starts_on, 'overlaps an existing owned pass season') if siblings.exists?
  end
end
