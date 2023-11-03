# frozen_string_literal: true

FactoryBot.define do
  factory :room do
    name { ['Master', 'Spare Room', 'Main Room'].sample }
    room_type { Room.room_type.keys.sample }
  end
end
