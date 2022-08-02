# frozen_string_literal: true

class Token < ApplicationRecord
  include Enhanceable
  include LinkedRails::Model
  include LinkedRails::Model::Filtering
  include ApplicationModel
  include Broadcastable
  extend URITemplateHelper

  enhance LinkedRails::Enhancements::Updatable
  enhance LinkedRails::Enhancements::Destroyable
  collection_options(
    include_members: true,
    parent_iri: -> { %w[tokens] + (parent&.iri_elements || []) }
  )

  before_create :set_token_type
  attr_accessor :creator

  scope :active, lambda {
    where('retracted_at IS NULL AND (expires_at IS NULL OR expires_at > ?)'\
          ' AND (max_usages IS NULL OR usages < max_usages)',
          Time.current)
  }
  validates :group_id, presence: true, numericality: {greater_than: 0}

  paginates_per 50

  def active?
    retracted_at.nil? && (expires_at.nil? || expires_at > Time.current) && (max_usages.nil? || usages < max_usages)
  end

  def display_name; end

  def parent_collections(user_context)
    [group.bearer_token_collection(user_context: user_context)]
  end

  def iri_opts
    {id: secret}
  end

  def generate_token
    self.secret = email.present? ? SecureRandom.urlsafe_base64(128) : human_readable_token unless secret?
  end

  def login_iri
    RDF::URI("https://#{ActsAsTenant.current_tenant.iri_prefix}/u/session/new?#{{redirect_url: iri}.to_param}")
  end

  def to_param
    secret
  end

  def update_usage!
    increment(:usages)
    update!(last_used_at: Time.current)
  end

  def group
    @group ||= group_id && Group.new(id: group_id)
  end

  def group=(group)
    @group = group
    self.group_id = group&.id
  end

  def root
    group.organization
  end

  def singular_resource=(_val); end

  private

  def human_readable_token
    token = SecureRandom.urlsafe_base64(128).upcase.scan(/[123456789ACDEFGHJKLMNPQRTUVWXYZ]+/).join
    token.length >= 8 ? token[0...8] : human_readable_token
  end

  def set_token_type
    self.type ||= email.present? ? :EmailToken : :BearerToken
  end

  class << self
    def attributes_for_new(opts)
      parent = opts[:parent]
      {
        actor_iri: opts[:user_context].user.iri,
        creator: opts[:user_context].user,
        group: opts[:group] || parent.is_a?(Group) ? parent : nil,
        redirect_url: "https://#{ActsAsTenant.current_tenant.iri_prefix}"
      }
    end

    def ids_for_iris(scope)
      scope.pluck(:secret)
    end

    def iri_template
      @iri_template ||= LinkedRails::URITemplate.new('/tokens{/id}{#fragment}')
    end

    def parse_group_id(group_id)
      return group_id unless group_id.to_s.include?(LinkedRails.iri.to_s)

      path = group_id.gsub(LinkedRails.iri.to_s, '')
      uri_template(:groups_iri).extract(path)['id']
    end

    def requested_index_resource(params, user_context)
      group_id = params[name.underscore].try(:[], :group_id)
      return super unless group_id

      parent = Group.new(id: parse_group_id(group_id))
      collection_name = collection_from_parent_name(parent, params)

      parent.send(collection_name, index_collection_params(params, user_context)) if collection_name
    end

    def requested_single_resource(params, _user_context)
      find_by(secret: params[:id] || params[:token_id])
    end
    alias requested_singular_resource requested_single_resource

    def route_key
      ''
    end
  end
end
