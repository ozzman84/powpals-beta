# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'home#index'

  resource :user, only: %i[show edit update]
  resources :users, only: :index

  resource :guest_invitation, only: %i[show update]
  resources :guest_visits, only: %i[index show]
  resource :house_invitation, only: %i[show update]

  namespace :users do
    resources :lodgings do
      resources :house_seasons, only: %i[index show create update] do
        post :quote, on: :member
        resource :finance, only: %i[show update], controller: 'house_finances'
        resource :rent_collection, only: :show, controller: 'rent_collections'
        resources :house_ledger_entries, only: :create do
          resources :house_payments, only: :create
        end
      end
      resources :guest_stays, only: %i[index create update]
      resources :bed_requests, only: %i[index create update]
      resources :house_members, only: %i[index create update]
      resources :roommates, only: %i[create destroy]
      resource :my_payments, only: :show
      resources :rooms, only: %i[index create update destroy] do
        resources :beds, only: :update
      end
      resource :calendars, only: %i[show create destroy update] do
        get 'my_calendar', on: :member
      end
    end
  end

  get '/edit-profile', to: 'accounts#edit', as: 'edit_profile'
  patch '/edit-profile', to: 'accounts#update'
  delete '/owned_pass/:id', to: 'accounts#season_pass_destroy', as: 'remove_owned_pass'
  delete '/account_season_pass/:season_pass_id', to: 'accounts#season_pass_destroy', as: 'remove_season_pass'

  devise_for :accounts, controllers: {
    omniauth_callbacks: 'accounts/omniauth_callbacks',
    sessions: 'accounts/sessions',
    registrations: 'accounts/registrations'
  }
end
