# frozen_string_literal: true

require 'argu/whitelist_constraint'

Rails.application.routes.draw do
  root 'tokens#show'
  get 'verify', to: 'verifications#show', defaults: {format: :json_api}

  resources :tokens,
            as: :bearer,
            path: 'bearer/g/:group_id',
            only: :index,
            defaults: {format: :json_api},
            to: 'bearer_token#index'
  resources :tokens,
            as: :email,
            path: 'email/g/:group_id',
            only: :index,
            defaults: {format: :json_api},
            to: 'email_token#index'
  resources :tokens, path: '', param: :secret, only: %i[destroy create update], defaults: {format: :json_api}
  resources :tokens, path: '', param: :secret, only: [:show]

  constraints(Argu::WhitelistConstraint) do
    health_check_routes
  end
end
