# frozen_string_literal: true

class Calendar < ApplicationRecord
  belongs_to :user
  belongs_to :lodging

  validates :date, :user_id, :lodging_id, presence: true
  validates :date, uniqueness: { scope: %i[lodging_id user_id], message: 'A user cannot have a duplicatedate for a lodging' }

  enum status: {
    away: 'away',
    staying: 'staying',
    undecided: 'undecided'
  }
end
