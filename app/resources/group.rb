# frozen_string_literal: true

class Group < ActiveResourceModel
  include LinkedRails::Model
  self.collection_name = 'g'

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
    @bearer_tokens ||= BearerToken.where(root_id: root_id, group_id: id)
  end

  def build_child(klass)
    klass.new(group: self)
  end

  def email_tokens
    @email_tokens ||= EmailToken.where(root_id: root_id, group_id: id)
  end

  def iri_path(_opts = {})
    @iri_path ||=
      DynamicUriHelper
        .revert(argu_attribute(:iri), ActsAsTenant.current_tenant, old_frontend: true)
        .gsub(Rails.application.config.origin, '')
  end

  private

  def argu_attribute(method)
    fetch unless @fecthed
    @attributes[method]
  end

  def fetch
    original_id = id
    load(
      self.class.format.decode(connection.get(self.class.element_path(id, root_id: root_id), self.class.headers).body)
    )
    @attributes[:id] = original_id
    @fetched = true
  end
end
