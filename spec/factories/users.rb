# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    full_name = Faker::Fantasy::Tolkien.character

    full_name { full_name }
    first_name { full_name.split(' ').first }
    last_name { full_name.split(' ').last }
    preferred_name { Faker::Superhero.descriptor }
    address1 { Faker::Address.street_address }
    address2 { Faker::Address.secondary_address }
    city { Faker::Address.city }
    state { Faker::Address.state_abbr }
    zip_code { Faker::Address.zip }
    country { 'United States' }
    avatar_url do
      [
        'https://images.unsplash.com/photo-1491528323818-fdd1faba62cc?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80',
        'https://images.unsplash.com/photo-1550525811-e5869dd03032?ixlib=rb-1.2.1&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80',
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2.25&w=256&h=256&q=80',
        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80',
        'https://tecdn.b-cdn.net/img/new/avatars/5.webp',
        'https://tecdn.b-cdn.net/img/new/avatars/1.webp',
        'https://tecdn.b-cdn.net/img/new/avatars/2.webp'
      ].sample
    end
    ride_type { User.ride_types.keys.sample }
    level { User.levels.keys.sample }
    about { Faker::Lorem.paragraphs }
    phone_number { Faker::PhoneNumber.phone_number }
    allergies { %w[nuts fruit shellfish eggs milk].sample }

    association :account
  end
end
