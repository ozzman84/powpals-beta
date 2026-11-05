# frozen_string_literal: true

class Bed < ApplicationRecord
  belongs_to :room
  before_validation :set_capacity

  enum :size, {
    twin: 'twin',
    full: 'full',
    queen: 'queen',
    king: 'king',
    california_king: 'california_king'
  }, validate: true

  enum :style, {
    mattress: 'mattress',
    airmattress: 'airmattress',
    pullout: 'pullout',
    couch: 'couch',
    bunk: 'bunk'
  }, default: 'mattress', validate: true

  validates :capacity, numericality: { only_integer: true, greater_than: 0 }

  CAPACITY = {
    twin: 1,
    full: 2,
    queen: 2,
    king: 2,
    california_king: 2
  }.freeze

  private

  def set_capacity
    self.capacity ||= CAPACITY[size&.to_sym]
  end
end
