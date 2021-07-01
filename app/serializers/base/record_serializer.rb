# frozen_string_literal: true

class RecordSerializer < BaseSerializer
  attribute :iri
  attribute :created_at, predicate: NS.schema.dateCreated
  attribute :display_name, predicate: NS.schema.name, graph: NS.ll[:add]

  class << self
    def guest?(_object, params)
      params[:scope]&.doorkeeper_scopes&.include? 'guest'
    end
  end
end
