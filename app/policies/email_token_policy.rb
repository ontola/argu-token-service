# frozen_string_literal: true

class EmailTokenPolicy < TokenPolicy
  permit_attributes %i[addresses actor_iri message redirect_url root_id send_mail]
end
