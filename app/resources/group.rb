# frozen_string_literal: true

class Group < ActiveResourceModel
  include RailsLD::Model

  with_collection :bearer_tokens,
                  parent_uri_template_opts: ->(r) { {group_id: r.id} }
  with_collection :email_tokens,
                  parent_uri_template_opts: ->(r) { {group_id: r.id} }

  %i[organization].each do |method|
    define_method method do
      argu_attribute(method)
    end
  end

  def self.collection_name
    'g'
  end

  def bearer_tokens
    @bearer_tokens ||= BearerToken.where(group_id: id)
  end

  def build_child(klass)
    klass.new(group: self)
  end

  def email_tokens
    @email_tokens ||= EmailToken.where(group_id: id)
  end

  def iri_path(_opts = {})
    @iri_path ||= argu_attribute(:iri).gsub(Rails.application.config.origin, '')
  end

  private

  def argu_attribute(method)
    fetch unless @fecthed
    @attributes[method]
  end

  def fetch
    original_id = id
    load(
      self.class.format.decode(self.class.send(:connection).get(self.class.element_path(id), self.class.headers).body)
    )
    @attributes[:id] = original_id
    @fetched = true
  end
end
