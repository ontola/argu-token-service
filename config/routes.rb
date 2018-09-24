# frozen_string_literal: true

require 'argu/whitelist_constraint'

Rails.application.routes.draw do
  root 'tokens#show'
  get 'verify', to: 'verifications#show'

  resources :tokens,
            as: :bearer,
            path: 'bearer/g/:group_id',
            only: :index,
            to: 'bearer_token#index'
  resources :tokens,
            as: :email,
            path: 'email/g/:group_id',
            only: :index,
            to: 'email_token#index'
  resources :tokens, path: '', param: :secret, only: %i[destroy create update]
  resources :tokens, path: '', param: :secret, only: [:show] do
    resource :email_conflict, only: :show
  end

  constraints(Argu::WhitelistConstraint) do
    health_check_routes
  end
end
