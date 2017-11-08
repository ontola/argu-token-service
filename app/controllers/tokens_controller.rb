# frozen_string_literal: true

require 'token_creator'
require 'token_executor'

class TokensController < ApplicationController
  include ActionController::Helpers
  include ActionController::Flash
  include ActionController::Cookies
  rescue_from ActionController::UnpermittedParameters, with: :handle_unpermitted_parameters_error

  before_action :validate_active, only: :show
  before_action :authorize_action, except: %i[show]
  before_action :redirect_wrong_email, unless: :valid_email?, only: %i[show]

  def show
    token_executor.execute!
    redirect_to token_executor.redirect_url, notice: token_executor.notice(cookies[:locale])
  end

  def update
    if resource_by_secret.update(permit_params)
      render json: resource_by_secret
    else
      render json_api_error(400, resource_by_secret.errors)
    end
  end

  def create
    response.headers['location'] = token_creator.location
    render json: token_creator.tokens, status: 201 if token_creator.create!
  rescue ActiveRecord::ActiveRecordError => e
    render json_api_error(400, token_creator.errors || e.message)
  end

  def destroy
    resource_by_secret.update(retracted_at: DateTime.current)
    render status: 200
  end

  private

  def actor_iri
    params.require(:data).require(:attributes).permit(:actor_iri)[:actor_iri]
  end

  def authorize_action(resource_type = nil, resource_id = nil, action = nil)
    return super if [resource_type, resource_id, action].compact.present?
    super('Group', group_id, 'update')
    return unless action_name == 'create' && actor_iri.present?
    super('CurrentActor', actor_iri, 'show')
  end

  def authorize_redirect_resource
    api.authorize_redirect_resource(resource_by_secret)
  end

  def check_if_registered
    return super unless action_name == 'show'
    current_user || create_user || raise(Errors::UnauthorizedError)
  end

  def group_id
    @group_id ||= action_name == 'create' ? token_creator.group_id : resource_by_secret!.group_id
  end

  def handle_unauthorized_error
    return super unless action_name == 'show'
    if authorize_redirect_resource
      redirect_to_authorized_r
    else
      redirect_to argu_url('/users/sign_in', r: @_request.env['REQUEST_URI']), notice: I18n.t('please_login')
    end
  end

  def redirect_to_authorized_r
    cookies[:token] = resource_by_secret.iri if resource_by_secret.active?
    redirect_to resource_by_secret.redirect_url, notice: resource_by_secret.active? ? I18n.t('please_login') : nil
  end

  def handle_unpermitted_parameters_error(e)
    render json_api_error(422, e.message)
  end

  def permit_params
    params.require(:data).require(:attributes).permit(%i[redirect_url])
  end

  def create_user
    return unless resource_by_secret&.active? && resource_by_secret&.email
    @current_user = api.create_user(resource_by_secret.email)
  end

  def resource_by_secret
    @resource ||= Token.find_by(secret: params[:secret])
  end

  def resource_by_secret!
    resource_by_secret || raise(ActiveRecord::RecordNotFound)
  end

  def token_creator
    unless %w[bearerToken emailTokenRequest].include?(params.require(:data)[:type])
      raise ActionController::UnpermittedParameters.new(%w[type])
    end
    @token_creator ||= TokenCreator.new(params: params)
  end

  def token_executor(user = current_user)
    @token_executor ||= TokenExecutor.new(token: resource_by_secret!, user: user, api: api)
  end

  def validate_active
    return if resource_by_secret!.active?
    if api.user_is_group_member?(group_id)
      redirect_to resource_by_secret.redirect_url || argu_url, notice: I18n.t('already_member')
    else
      redirect_to argu_url('/token', token: params[:secret], error: 'inactive')
    end
  end

  def redirect_wrong_email
    redirect_to argu_url('/users/wrong_email', r: resource_by_secret.iri, email: resource_by_secret.email)
  end

  def valid_email?
    resource_by_secret.valid_email?(current_user)
  end
end
