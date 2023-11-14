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

  get '/edit-profile', to: 'accounts#edit', as: 'edit_profile'
  patch '/edit-profile', to: 'accounts#update'
  delete '/account_season_pass/:season_pass_id', to: 'accounts#season_pass_destroy', as: 'remove_season_pass'

  devise_for :accounts, controllers: {
    omniauth_callbacks: 'accounts/omniauth_callbacks',
    sessions: 'accounts/sessions',
    registrations: 'accounts/registrations'
  }
end
