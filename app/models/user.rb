# frozen_string_literal: true

class User < ApplicationRecord
  has_many :roommates
  has_many :lodgings, through: :roommates
  belongs_to :account
  has_many :calendars, dependent: :destroy

  validates :first_name, :last_name, :city, :state, presence: true
end
