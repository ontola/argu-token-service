# frozen_string_literal: true

class TokenCreator
  attr_accessor :tokens

  def initialize(params: [])
    self.batch = params.require(:data).require(:type) == 'emailTokenRequest'
    self.attribute_params = params.require(:data).require(:attributes)
    initialize_tokens
  end

  def create!
    batch? ? tokens.each(&:save!) : tokens.save!
  end

  def errors
    batch? ? tokens&.map(&:errors) : tokens&.errors
  end

  def group_id
    attribute_params.require(:group_id)
  end

  def location
    tokens.iri if tokens.is_a?(Token)
  end

  def root_id
    attribute_params.require(:root_id)
  end

  private

  attr_accessor :batch, :attribute_params
  alias batch? batch

  def addresses_param
    @addresses_param ||= attribute_params.require(:addresses).uniq
  end

  def batch_params
    params = attribute_params.permit(%i[actor_iri expires_at group_id root_id message redirect_url send_mail])
    invitees
      .reject { |invitee| existing_tokens.include?(invitee[:email]) }
      .map { |invitee| params.merge(invitee: invitee[:invitee], email: invitee[:email]) }
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

  def initialize_tokens
    self.tokens = batch? ? batch_params.map { |a| Token.new(a) } : Token.new(single_params)
    batch? ? tokens.each(&:generate_token) : tokens.generate_token
  end

  def invitees
    @invitees ||=
      addresses_param
        .map { |invitee| {invitee: invitee, email: invitee.include?('@') ? invitee : User.find(invitee).email} }
        .uniq { |invitee| invitee[:email] }
  end

  def redirect_url_param
    attribute_params.permit(:redirect_url)[:redirect_url]
  end

  def single_params
    attribute_params.permit(%i[actor_iri expires_at group_id root_id message redirect_url])
  end
end
