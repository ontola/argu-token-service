# frozen_string_literal: true

class BearerTokenForm < ApplicationForm
  include RegexHelper

  field :redirect_url,
        min_count: 1
  field :max_usages
  field :expires_at

  hidden do
    field :root_id
  end
end
