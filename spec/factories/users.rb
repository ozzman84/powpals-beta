# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    full_name = Faker::Fantasy::Tolkien.character

    full_name { full_name }
    first_name { full_name.split(' ').first }
    last_name { full_name.split(' ').last }
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

    association :account
  end
end
