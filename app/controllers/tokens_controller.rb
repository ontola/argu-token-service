# frozen_string_literal: true
class TokensController < ApplicationController
  prepend_before_action :validate_active, only: :show
  skip_before_action :check_if_registered, only: :verify
  before_action :authorize_action, only: %i(index create destroy)
  before_action :redirect_wrong_email, if: :wrong_email?, only: %i(show)

  def show
    case post_membership.status
    when 201
      resource_by_secret.update_usage!
      redirect_to argu_url("/g/#{resource_by_secret.group_id}", welcome: true)
    when 304
      redirect_to argu_url("/g/#{resource_by_secret.group_id}")
    end
  end

  # Used by the argu_service to verify whether the POST made in #post_membership is valid
  # GET /verify
  def verify
    hash = JWT.decode(params[:jwt], Rails.application.secrets.jwt_encryption_token, algorithm: 'HS256')[0]
    Token.active.find_by!(hash)
    head 200
  end

  def index
    render json: index_by_token_type, include: {emails: :email_events}
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

  def send_mail_param
    params.require(:data).require(:attributes).require(:send_mail)
  end

  def authorize_action
    case action_name
    when 'index'
      super('Group', params.fetch(:group_id), 'update')
    when 'create'
      super('Group', permit_params.fetch(:group_id), 'update')
    when 'destroy'
      super('Group', resource_by_secret.group_id, 'update')
    end
  end

  def batch_params
    req = params.require(:data).require(:attributes).require(:addresses).uniq
    exist = Token.where(group_id: permit_params[:group_id], email: req, usages: 0).pluck(:email)

    (req - exist).map { |email| permit_params.to_h.merge(email: email, max_usages: 1, send_mail: send_mail_param) }
  end

  def create_tokens
    if %w(bearerToken emailTokenRequest).include?(params[:data][:type])
      Token.create!(params[:data][:type] == 'emailTokenRequest' ? batch_params : permit_params)
    else
      render json_api_error(422, 'Please provide a valid type')
    end
  end

  def handle_unauthorized_error
    return super unless action_name == 'show'
    redirect_to argu_url('/users/sign_in', r: @_request.env['REQUEST_URI'])
  end

  def index_by_token_type
    case params[:token_type]
    when 'bearer'
      Token.bearer.active.where(group_id: params[:group_id])
    when 'email'
      Token.email.active.where(group_id: params[:group_id])
    end
  end

  def permit_params
    params.require(:data).require(:attributes).permit(%i(expires_at group_id))
  end

  def post_membership
    @post_membership ||= argu_token.post(
      "/g/#{resource_by_secret.group_id}/memberships",
      body: {
        shortname: current_user.url,
        token: resource_by_secret.secret
      },
      headers: {accept: 'application/json'}
    )
  end

  def resource_by_secret
    @resource ||= Token.find_by!(secret: params[:secret])
  end

  def validate_active
    render_status(403, 'status/403_inactive.html') unless resource_by_secret.active?
  end

  def redirect_wrong_email
    redirect_to argu_url('/users/wrong_email', r: resource_by_secret.context_id, email: resource_by_secret.email)
  end

  def wrong_email?
    resource_by_secret.email.present? &&
      resource_by_secret.email != current_user.email &&
      !current_user.secondary_emails.include?(resource_by_secret.email)
  end
end
