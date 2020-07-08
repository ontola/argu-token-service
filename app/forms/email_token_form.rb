# frozen_string_literal: true

class EmailTokenForm < ApplicationForm
  include RegexHelper

  field :addresses, max_length: 5000, pattern: /\A(#{RegexHelper::SINGLE_EMAIL.source},?\s?)+\z/
  field :message, max_length: 5000
  field :redirect_url

  hidden do
    field :send_mail
    field :root_id
  end

  footer do
    actor_selector(:actor_iri)
  end
end
