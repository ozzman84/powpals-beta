# frozen_string_literal: true

class Room < ApplicationRecord
  belongs_to :lodging
  has_many :beds, dependent: :destroy
  accepts_nested_attributes_for :beds

  validates :name, presence: true
  validates :name, uniqueness: { scope: :lodging_id, case_sensitive: false }, if: :will_save_change_to_name?

  enum :room_type, {
    bedroom: 'bedroom',
    livingroom: 'livingroom'
  }, default: 'bedroom', validate: true
end
