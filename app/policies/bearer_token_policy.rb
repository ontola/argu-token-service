# frozen_string_literal: true

class BearerTokenPolicy < TokenPolicy
  def permitted_attributes
    %i[redirect_url root_id]
  end
end
