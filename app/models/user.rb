# frozen_string_literal: true

class User < ApplicationRecord
  has_many :roommates
  has_many :lodgings, through: :roommates
  belongs_to :account
  has_many :calendars, dependent: :destroy

  validates :first_name, :last_name, :city, :state, :ride_type, presence: true, length: { minimum: 2 }

  enum :ride_type, {
    ski: 'ski',
    snowboard: 'snowboard',
    both: 'both'
  }, prefix: true

  enum :level, {
    beginner: 'beginner',
    intermediate: 'intermediate',
    advanced: 'advanced'
  }, _default: 'beginner'

  def initials
    name = first_name.nil? ? '' : first_name.first.capitalize
    name += last_name.nil? ? '' : last_name.first.capitalize
    name
  end
end
