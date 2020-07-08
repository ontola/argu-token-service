# frozen_string_literal: true

class BearerTokenForm < ApplicationForm
  include RegexHelper

  field :redirect_url

  hidden do
    field :root_id
  end
end
