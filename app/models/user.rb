# frozen_string_literal: true

class User < ApplicationRecord
  has_many :roommates, dependent: :destroy
  has_many :lodgings, through: :roommates
  belongs_to :account
  has_many :calendars, dependent: :destroy

  validates :account_id, uniqueness: true

  validates :first_name, :last_name, :ride_type, presence: true, length: { minimum: 2 }

  enum :ride_type, {
    ski: 'ski',
    snowboard: 'snowboard',
    both: 'ski and snowboard'
  }, prefix: true, default: 'ski', validate: true

  enum :level, {
    beginner: 'beginner',
    intermediate: 'intermediate',
    advanced: 'advanced'
  }, default: 'beginner', validate: true

  def initials
    "#{first_name&.first || ''}#{last_name&.first || ''}".upcase
  end
end
