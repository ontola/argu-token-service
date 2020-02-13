# frozen_string_literal: true

class Group < ActiveResourceModel
  include LinkedRails::Model
  self.collection_name = 'g'
  attr_accessor :fetched

  with_collection :bearer_tokens,
                  parent_uri_template_opts: ->(r) { {group_id: r.id} }
  with_collection :email_tokens,
                  parent_uri_template_opts: ->(r) { {group_id: r.id} }

  %i[organization display_name].each do |method|
    define_method method do
      argu_attribute(method)
    end
  end

  def bearer_tokens
    @bearer_tokens ||= BearerToken.where(group_id: id)
  end

  def build_child(klass)
    klass.new(group: self)
  end

  def email_tokens
    @email_tokens ||= EmailToken.where(root_id: ActsAsTenant.current_tenant.uuid, group_id: id)
  end

  def self.find_by(opts)
    return unless opts.keys == %i[id]

    resource = find(opts[:id])
    resource.id = opts[:id]
    resource.fetched = true
    resource
  end

  def iri_path(_opts = {})
    @iri_path ||= argu_attribute(:iri).gsub(Rails.application.config.origin, '')
  end

  private

  def argu_attribute(method)
    fetch unless fetched
    @attributes[method]
  end

  def fetch
    original_id = id
    group = id.to_s.scan(/\D/).present? ? Group.find(:one, from: id) : Group.find(id)
    @attributes = group.attributes
    @attributes[:id] = original_id
    @fetched = true
  end
end
