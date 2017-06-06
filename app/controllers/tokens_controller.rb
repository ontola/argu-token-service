# frozen_string_literal: true
class TokensController < ApplicationController
  skip_before_action :check_if_registered, only: :verify
  before_action :validate_active, only: :show
  before_action :authorize_action, only: %i(index create destroy)
  before_action :redirect_wrong_email, unless: :valid_email?, only: %i(show)

  def show
    membership_created = resource_by_secret.post_membership(argu_token, current_user).status == 201
    resource_by_secret.update_usage! if membership_created
    redirect_to argu_url("/g/#{group_id}", {welcome: membership_created}.delete_if { |_k, v| !v })
  end

  # Used by the argu_service to verify whether the POST made in #post_membership is valid
  # GET /verify
  def verify
    hash = JWT.decode(params[:jwt], Rails.application.secrets.jwt_encryption_token, algorithm: 'HS256')[0]
    Token.active.find_by!(hash)
    head 200
  end

  def create
    @tokens = create_tokens
    response.headers['location'] = url_for(@tokens) if @tokens.is_a?(Token)
    render json: @tokens, status: 201 if @tokens
  rescue ActiveRecord::ActiveRecordError => e
    message = @tokens.present? ? @tokens.errors.full_messages : e.message
    render json_api_error(400, message)
  end

  def destroy
    resource_by_secret.update(retracted_at: DateTime.current)
    render status: 200
  rescue ActiveRecord::RecordNotFound
    render json_api_error(404, 'Please provide a valid token')
  end

  private

  def addresses_param
    @addresses_param ||= params.require(:data).require(:attributes).require(:addresses).uniq
  end

  def authorize_action(resource_type = nil, resource_id = nil, action = nil)
    return super if [resource_type, resource_id, action].compact.present?
    super('Group', group_id, 'update')
    return unless action_name == 'create' && permit_params[:profile_iri].present?
    super('CurrentActor', permit_params[:profile_iri], 'show')
  end

  def batch_params
    params = permit_params.to_h.merge(max_usages: 1, send_mail: send_mail_param)
    existing_tokens = Token.active.where(group_id: group_id, email: addresses_param, usages: 0)
    (addresses_param - existing_tokens.pluck(:email)).map { |email| params.merge(email: email) }
  end

  def create_tokens
    if %w(bearerToken emailTokenRequest).include?(params[:data][:type])
      Token.create!(params[:data][:type] == 'emailTokenRequest' ? batch_params : permit_params)
    else
      render json_api_error(422, 'Please provide a valid type')
    end
  end

  def current_user_is_group_member?
    return unless current_user.email == resource_by_secret.email
    authorize_action('Group', group_id, 'is_member')
  rescue OAuth2::Error => e
    [401, 403].include?(e.response.status) ? false : handle_oauth_error(e)
  end

  def group_id
    @group_id ||= action_name == 'create' ? permit_params.fetch(:group_id) : resource_by_secret.group_id
  end

  def handle_unauthorized_error
    return super unless action_name == 'show'
    redirect_to argu_url('/users/sign_in', r: @_request.env['REQUEST_URI'])
  end

  def permit_params
    params.require(:data).require(:attributes).permit(%i(expires_at group_id message profile_iri))
  end

  def resource_by_secret
    @resource ||= Token.find_by!(secret: params[:secret])
  end

  def send_mail_param
    params.require(:data).require(:attributes).require(:send_mail)
  end

  def validate_active
    return if resource_by_secret.active?
    if current_user_is_group_member?
      redirect_to argu_url("/g/#{group_id}")
    else
      render_status(403, 'status/403_inactive.html')
    end
  end

  def redirect_wrong_email
    redirect_to argu_url('/users/wrong_email', r: resource_by_secret.context_id, email: resource_by_secret.email)
  end

  def valid_email?
    resource_by_secret.valid_email?(current_user)
  end
end
