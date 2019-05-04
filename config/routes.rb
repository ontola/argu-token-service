# frozen_string_literal: true

require 'argu/whitelist_constraint'
require_relative '../app/models/bearer_token'
require_relative '../app/models/email_token'

Rails.application.routes.draw do
  concerns_from_enhancements

  scope :tokens do
    root 'tokens#show'
    get 'verify', to: 'verifications#show'

    %i[bearer email].each do |type|
      resources :"#{type}_tokens", path: "#{type}/g/:group_id", only: %i[new create index]
    end
    resources :tokens, path: '', param: :secret, only: %i[create update show destroy] do
      post :show, on: :member
      get :delete, on: :member
      resource :email_conflict, only: %i[show update]
    end

    constraints(Argu::WhitelistConstraint) do
      health_check_routes
    end
  end
end
