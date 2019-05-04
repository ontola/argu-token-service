# frozen_string_literal: true

class EmailConflictSerializer < BaseSerializer
  attribute :label, predicate: NS::SCHEMA[:name]
  attribute :description, predicate: NS::SCHEMA[:text]
  triples :action_triples

  def action_triples
    object.logout_action_triples + object.couple_action_triples
  end
end
