# frozen_string_literal: true
require 'argu/whitelist_constraint'

Rails.application.routes.draw do
  get 'verify', to: 'tokens#verify', defaults: {format: :json_api}

  resources :tokens, path: 'bearer/g/:group_id', only: :index, defaults: {format: :json_api}, to: 'bearer_token#index'
  resources :tokens, path: 'email/g/:group_id', only: :index, defaults: {format: :json_api}, to: 'email_token#index'
  resources :tokens, path: '', param: :secret, only: [:destroy, :create], defaults: {format: :json_api}
  resources :tokens, path: '', param: :secret, only: [:show]

  constraints(Argu::WhitelistConstraint) do
    health_check_routes
  end
end
