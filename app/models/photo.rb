class Photo < ApplicationRecord
    belongs_to :lodging
    has_one_attached :photo
end
