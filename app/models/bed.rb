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
    bunk: 'bunk',
    sleeping_bag: 'sleeping bag',
    chair: 'chair'
  }, default: 'mattress', validate: true

  validates :label, length: { maximum: 100 }, allow_blank: true

  validates :capacity, numericality: { only_integer: true, greater_than: 0 }

  CAPACITY = {
    twin: 1,
    full: 2,
    queen: 2,
    king: 2,
    california_king: 2
  }.freeze

  def inventory_name
    label.presence || [size&.humanize, style&.humanize].compact.join(' ')
  end

  private

  def set_capacity
    self.capacity ||= CAPACITY[size&.to_sym]
  end
end
