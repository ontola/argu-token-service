# frozen_string_literal: true

class EmailTokenPolicy < TokenPolicy
  permit_attributes %i[redirect_url]
  permit_attributes %i[actor_iri message root_id send_mail], new_record: true
  permit_array_attributes %i[addresses], new_record: true
end
