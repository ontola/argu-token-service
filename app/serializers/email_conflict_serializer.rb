# frozen_string_literal: true

class EmailConflictSerializer < BaseSerializer
  attribute :label, predicate: NS.schema.name
  attribute :description, predicate: NS.schema.text

  class << self
    def action_triples(object, _params)
      object.logout_action_triples + object.couple_action_triples
    end
  end
end
