# frozen_string_literal: true

require 'argu/inputs/multiple_email_input'

class EmailTokenForm < ApplicationForm
  include RegexHelper

  field :addresses,
        max_length: 5000,
        pattern: /(#{RegexHelper::SINGLE_EMAIL.source},?\s?)+/,
        input_field: Inputs::MultipleEmailInput
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
