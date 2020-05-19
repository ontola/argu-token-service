# frozen_string_literal: true

class EmailConflictSerializer < BaseSerializer
  attribute :label, predicate: NS::SCHEMA[:name]
  attribute :description, predicate: NS::SCHEMA[:text]
  statements :action_triples

  class << self
    def action_triples(object, _params)
      object.logout_action_triples + object.couple_action_triples
    end
  end
end
