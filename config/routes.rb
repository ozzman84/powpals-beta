# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'home#index'

  namespace :users do
    resources :lodgings do
      resources :rooms, only: %i[index create destroy]
      resource :calendars, only: %i[show create destroy update] do
        get 'my_calendar', on: :member
      end
    end
  end

  devise_for :accounts, controllers: {
    omniauth_callbacks: 'accounts/omniauth_callbacks',
    sessions: 'accounts/sessions',
    registrations: 'accounts/registrations'
  }
end
