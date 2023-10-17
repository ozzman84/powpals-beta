# frozen_string_literal: true

class Bed < ApplicationRecord
  belongs_to :room

  enum size: {
    twin: 'twin',
    full: 'full',
    queen: 'queen',
    king: 'king',
    california_king: 'california_king'
  }

  enum style: {
    mattress: 'mattress',
    airmattress: 'airmattress',
    pullout: 'pullout',
    couch: 'couch',
    bunk: 'bunk'
  }, _default: 'mattress'
end
