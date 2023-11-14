# frozen_string_literal: true

class Lodging < ApplicationRecord
  has_many :roommates, dependent: :destroy
  has_many :users, through: :roommates
  has_many :rooms
  has_many :calendars, dependent: :destroy

  #   validates :max_capacity, numericality: { greater_than: 0, less_than: 101 }, if: { status: :published}

  enum status: {
    draft: 'draft',
    published: 'published',
    archived: 'archived'
  }, _default: 'draft'

  def full_address
    st = street
    st = street + " #{address2}" if address2
    st + " #{city}, #{state} #{zip_code}"
  end
end
