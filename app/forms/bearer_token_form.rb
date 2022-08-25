# frozen_string_literal: true

class BearerTokenForm < ApplicationForm
  include RegexHelper

  field :redirect_url,
        min_count: 1
  field :max_usages,
        min_count: 1
  field :expires_at,
        min_count: 1

  hidden do
    field :root_id
  end
end
