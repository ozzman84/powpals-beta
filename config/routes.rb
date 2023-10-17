# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'home#index'

  namespace :users do
    resources :lodgings do
      resources :photos, only: [:index, :create, :destroy]
      resources :rooms, only: %i[index create destroy]
    end
  end

  devise_for :users, controllers: {
    omniauth_callbacks: 'users/omniauth_callbacks',
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
end
