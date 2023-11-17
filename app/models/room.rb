# frozen_string_literal: true

class Room < ApplicationRecord
  belongs_to :lodging
  has_many :beds
  accepts_nested_attributes_for :beds

  validates :name, presence: true

  enum room_type: {
    bedroom: 'bedroom',
    livingroom: 'livingroom'
  }, _default: 'bedroom'
end
