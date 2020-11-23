# frozen_string_literal: true

class EmailTokenPolicy < TokenPolicy
  permit_attributes %i[actor_iri message redirect_url root_id send_mail]
  permit_array_attributes %i[addresses]
end
