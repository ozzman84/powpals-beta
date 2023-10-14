class Bed < ApplicationRecord
  belongs_to :room

  enum size: {
    twin: 1,
    full: 1,
    queen: 2,
    king: 3,
    california_king: 3,
  }

  enum style: {
    mattress: "mattress",
    airmattress: "airmattress",
    pullout: "pullout",
    couch: "couch",
    bunk: "bunk",
  }, default: "mattress"
end
