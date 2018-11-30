# frozen_string_literal: true

class Group
  include ActiveModel::Model
  include Iriable
  include Ldable

  attr_accessor :id

  with_collection :bearer_tokens,
                  association_class: Token,
                  parent_uri_template: :tokens_bearer_collection_iri,
                  parent_uri_template_opts: ->(r) { {group_id: r.id} }
  with_collection :email_tokens,
                  association_class: Token,
                  parent_uri_template: :tokens_email_collection_iri,
                  parent_uri_template_opts: ->(r) { {group_id: r.id} }

  def initialize(id: nil)
    self.id = id
  end

  def bearer_tokens
    @bearer_tokens || Token.bearer.where(group_id: id)
  end

  def email_tokens
    @email_tokens || Token.email.where(group_id: id)
  end
end
