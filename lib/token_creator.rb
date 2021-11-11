# frozen_string_literal: true

class TokenCreator
  attr_accessor :actor_iri, :group_id, :tokens, :params

  def initialize(actor_iri, group_id, params: [])
    self.actor_iri = actor_iri
    self.group_id = group_id
    self.params = params
    initialize_tokens
  end

  def create!
    batch? ? tokens.each(&:save!) : tokens.save!
  end

  def errors
    batch? ? tokens&.map(&:errors) : tokens&.errors
  end

  def location
    tokens.iri if tokens.is_a?(Token)
  end

  def root_id
    ActsAsTenant.current_tenant.uuid || params.require(:root_id)
  end

  def type
    @type ||= params.key?(:addresses) ? :email : :bearer
  end

  private

  def addresses_param
    @addresses_param ||=
      (params[:addresses].is_a?(String) ? params[:addresses].split(',').map(&:strip) : params[:addresses]).uniq
  end

  def batch?
    type == :email
  end

  def batch_params
    invitees
      .reject { |invitee| existing_tokens.include?(invitee[:email]) }
      .map { |invitee| single_params.merge(invitee: invitee[:invitee], email: invitee[:email]) }
  end

  def existing_tokens
    @existing_tokens ||=
      Token
        .active
        .where(
          root_id: root_id,
          group_id: group_id,
          usages: 0,
          redirect_url: redirect_url_param,
          email: invitees.map { |i| i[:email] }
        ).pluck(:email)
  end

  def find_invitee(id)
    User.find(id)
  end

  def initialize_tokens
    self.tokens = batch? ? batch_params.map { |a| token_class.new(a) } : token_class.new(single_params)
    batch? ? tokens.each(&:generate_token) : tokens.generate_token
  end

  def invitees
    @invitees ||=
      addresses_param
        .map { |invitee| {invitee: invitee, email: invitee.include?('@') ? invitee : find_invitee(invitee).email} }
        .uniq { |invitee| invitee[:email] }
  end

  def redirect_url_param
    params[:redirect_url]
  end

  def single_params
    @single_params ||=
      params
        .slice(:expires_at, :max_usages, :message, :redirect_url, :send_mail)
        .merge(actor_iri: actor_iri, group_id: group_id, root_id: root_id)
  end

  def token_class
    type == :email ? EmailToken : Token
  end
end
