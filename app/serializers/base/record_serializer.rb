# frozen_string_literal: true

class RecordSerializer < BaseSerializer
  attribute :iri
  attribute :created_at, predicate: NS::SCHEMA[:dateCreated]
  attribute :display_name, predicate: NS::SCHEMA[:name], graph: NS::LL[:add]

  def export?
    scope&.doorkeeper_scopes&.include? 'export'
  end

  def guest?
    scope&.doorkeeper_scopes&.include? 'guest'
  end
end
