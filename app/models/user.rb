# frozen_string_literal: true

class User < ApplicationRecord
  has_many :roommates
  has_many :lodgings, through: :roommates
  belongs_to :account
  has_many :calendars, dependent: :destroy
  has_many :user_season_passes
  has_many :season_passes, through: :user_season_passes
end
