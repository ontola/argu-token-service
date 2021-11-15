# frozen_string_literal: true

class Group < ActiveResourceModel
  self.collection_name = 'g'
  attr_accessor :fetched

  with_collection :bearer_tokens
  with_collection :email_tokens

  %i[organization display_name].each do |method|
    define_method method do
      argu_attribute(method)
    end
  end

  def bearer_tokens
    @bearer_tokens ||= ::BearerToken.where(group_id: id)
  end

  def email_tokens
    @email_tokens ||= ::EmailToken.where(root_id: ActsAsTenant.current_tenant.uuid, group_id: id)
  end

  def iri(_opts = {})
    @iri ||= RDF::URI(argu_attribute(:iri))
  end

  private

  def argu_attribute(method)
    fetch unless fetched
    @attributes[method]
  end

  def fetch
    original_id = id
    group = id.to_s.include?('/') ? Group.find(:one, from: id) : Group.find(id)
    @attributes = group.attributes
    @attributes[:id] = original_id
    @fetched = true
  end

  class << self
    def attributes_for_new(opts = {})
      {group: opts[:parent]}.merge(super)
    end

    def find_by(opts)
      return unless opts.keys == %i[id]

      resource = find(opts[:id])
      resource.id = opts[:id]
      resource.fetched = true
      resource
    end

    def route_key
      :g
    end
  end
end
