# frozen_string_literal: true

require 'argu/inputs/multiple_email_input'

class EmailTokenForm < ApplicationForm
  include RegexHelper

  field :addresses,
        max_count: 5000,
        min_count: 1,
        pattern: /(#{RegexHelper::SINGLE_EMAIL.source},?\s?)+/,
        input_field: Inputs::MultipleEmailInput
  field :message,
        max_length: 5000,
        min_count: 1
  field :redirect_url,
        min_count: 1

  hidden do
    field :send_mail
    field :root_id
  end

  footer do
    actor_selector(:actor_iri)
  end
end
