# frozen_string_literal: true
Rails.application.routes.draw do
  get 'verify', to: 'tokens#verify', defaults: {format: :json}
  get 'g/:group_id', to: 'tokens#index', defaults: {format: :json}

  resources :tokens, path: '', param: :secret, only: [:destroy, :create], defaults: {format: :json}
  resources :tokens, path: '', param: :secret, only: [:show]
end
