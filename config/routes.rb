# frozen_string_literal: true
require 'argu/whitelist_constraint'

Rails.application.routes.draw do
  get 'verify', to: 'tokens#verify', defaults: {format: :json_api}
  get '*token_type/g/:group_id',
      to: 'tokens#index',
      defaults: {format: :json_api},
      constraints: {token_type: 'bearer|email'}

  resources :tokens, path: '', param: :secret, only: [:destroy, :create], defaults: {format: :json_api}
  resources :tokens, path: '', param: :secret, only: [:show]

  constraints(Argu::WhitelistConstraint) do
    health_check_routes
  end
end
