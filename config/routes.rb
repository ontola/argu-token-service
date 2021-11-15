# frozen_string_literal: true

require_relative '../app/models/bearer_token'
require_relative '../app/models/email_token'

Rails.application.routes.draw do
  use_linked_rails(
    current_user: :current_user,
    forms: :forms
  )

  root 'tokens#show'
  get 'verify', to: 'verifications#show'
  resources :tokens, only: :show

  singular_linked_resource(EmailConflict)
  linked_resource(EmailToken)
  linked_resource(BearerToken)
  linked_resource(Group)
  linked_resource(Token, collection: false) do
    post '', to: 'tokens#accept', singular_route: true
  end

  constraints(LinkedRails::Constraints::Whitelist) do
    health_check_routes
  end
end
