# frozen_string_literal: true

class Lodging < ApplicationRecord
  has_many :roommates
  has_many :users, through: :roommates
  has_many :rooms

  #   validates :max_capacity, numericality: { greater_than: 0, less_than: 101 }, if: { status: :published}

  enum status: {
    draft: 'draft',
    published: 'published',
    archived: 'archived'
  }, _default: 'draft'
end
