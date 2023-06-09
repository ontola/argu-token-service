# frozen_string_literal: true

class BearerTokenPolicy < TokenPolicy
  permit_attributes %i[redirect_url root_id max_usages expires_at]
end
