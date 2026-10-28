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

  CAPACITY = {
    twin: 1,
    full: 1,
    queen: 2,
    king: 3,
    california_king: 3
  }.freeze

  private

  def set_capacity
    self.capacity = CAPACITY[size&.to_sym]
  end
end
