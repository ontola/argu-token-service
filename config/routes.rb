# frozen_string_literal: true
Rails.application.routes.draw do
  get 'verify', to: 'tokens#verify', defaults: {format: :json_api}
  get 'bearer/g/:group_id', to: 'tokens#index', defaults: {format: :json_api}

  resources :tokens, path: '', param: :secret, only: [:destroy, :create], defaults: {format: :json_api}
  resources :tokens, path: '', param: :secret, only: [:show]
end
