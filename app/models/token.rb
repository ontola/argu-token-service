# frozen_string_literal: true

class Token < ApplicationRecord
  include Enhanceable
  include LinkedRails::Model
  include LinkedRails::Model::Filtering
  include ApplicationModel
  include Broadcastable
  enhance LinkedRails::Enhancements::Tableable
  enhance LinkedRails::Enhancements::Indexable

  before_create :set_token_type

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
    {secret: secret}
  end

  def generate_token
    self.secret = email.present? ? SecureRandom.urlsafe_base64(128) : human_readable_token unless secret?
  end

  def login_iri
    RDF::URI("https://#{ActsAsTenant.current_tenant.iri_prefix}/u/sign_in?#{{redirect_url: iri}.to_param}")
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
      parent = opts[:collection]&.parent
      {
        actor_iri: opts[:user_context].user.iri,
        group: opts[:group] || parent.is_a?(Group) ? parent : nil,
        redirect_url: "https://#{ActsAsTenant.current_tenant.iri_prefix}"
      }
    end
  end
end
