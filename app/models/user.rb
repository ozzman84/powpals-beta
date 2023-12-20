# frozen_string_literal: true

class User < ApplicationRecord
  has_many :roommates
  has_many :lodgings, through: :roommates
  belongs_to :account
  has_many :calendars, dependent: :destroy
  has_one_attached :avatar_url

  validates :first_name, :last_name, :ride_type, presence: true, length: { minimum: 2 }

  enum :ride_type, {
    ski: 'ski',
    snowboard: 'snowboard',
    both: 'ski and snowboard'
  }, prefix: true, _default: 'ski'

  enum :level, {
    beginner: 'beginner',
    intermediate: 'intermediate',
    advanced: 'advanced'
  }, _default: 'beginner'
end
