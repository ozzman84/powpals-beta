class Room < ApplicationRecord
  belongs_to :lodging
  has_many :beds
end
