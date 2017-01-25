# frozen_string_literal: true
class TokensController < ApplicationController
  prepend_before_action :validate_active, only: :show
  skip_before_action :check_if_registered, only: :verify
  before_action :authorize_action, only: %i(index create destroy)

  def show
    case post_membership.status
    when 201
      resource_by_secret.increment!(:usages)
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
    @tokens = Token.active.where(group_id: params[:group_id])

    render json: @tokens
  end

  def create
    @token = Token.create!(permit_params)
    response.headers['location'] = url_for(@token)
    render json: @token, status: 201
  rescue ActiveRecord::ActiveRecordError
    render json_api_error(400, *@token.errors.full_messages)
  end

  def destroy
    resource_by_secret.update(retracted_at: DateTime.current)
    render status: 200
  rescue ActiveRecord::RecordNotFound
    render json_api_error(404, 'Please provide a valid token')
  end

  private

  def authorize_action
    group_id = case action_name
               when 'index'
                 params.fetch(:group_id)
               when 'create'
                 permit_params.fetch(:group_id)
               when 'destroy'
                 resource_by_secret.group_id
               end
    super('Group', group_id, 'update')
  end

  def handle_unauthorized_error
    return super unless action_name == 'show'
    redirect_to argu_url('/users/sign_in', r: @_request.env['REQUEST_URI'])
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
end
