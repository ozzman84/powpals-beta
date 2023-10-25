# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'home#index'

  namespace :users do
    resources :lodgings do
      resources :rooms, only: %i[index create destroy]
      resources :lodging_calendars, except: %i[new edit] do
        collection do
          get :my_calendar
        end
      end
    end
  end

  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
end
