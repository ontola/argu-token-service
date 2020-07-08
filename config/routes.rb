# frozen_string_literal: true

require 'argu/whitelist_constraint'
require_relative '../app/models/bearer_token'
require_relative '../app/models/email_token'

Rails.application.routes.draw do
  concern :nested_actionable do
    namespace :actions do
      resources :items, path: '', only: %i[index show], collection: @scope.parent.try(:[], :controller)
    end
  end

  root 'tokens#show'
  get 'verify', to: 'verifications#show'
  get '/forms/:id', to: 'forms#show'
  get '/forms/:module/:id', to: 'forms#show'

  %i[bearer email].each do |type|
    resources :"#{type}_tokens", path: "#{type}/g/:group_id", only: %i[new create index] do
      collection do
        concerns :nested_actionable
      end
    end
  end
  resources :tokens, path: '', param: :secret, only: %i[create update show destroy] do
    include_route_concerns(klass: [EmailToken, BearerToken])
    post :show, on: :member
    get :delete, on: :member
    resource :email_conflict, only: %i[show update], path: :email_conflict
  end

  constraints(Argu::WhitelistConstraint) do
    health_check_routes
  end
end
