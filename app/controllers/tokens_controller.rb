# frozen_string_literal: true

require 'token_creator'
require 'token_executor'

class TokensController < ApplicationController # rubocop:disable Metrics/ClassLength
  include ActionController::Helpers
  include ActionController::Flash
  include ActionController::Cookies
  active_response :show, :update, :create, :destroy

  before_action :handle_inactive_token, only: :show, unless: :token_active?
  before_action :authorize_action, except: %i[show]
  before_action :redirect_wrong_email, unless: :valid_email?, only: %i[show]

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
    return true if request.head?
    return super unless action_name == 'show'
    current_user || create_user || raise(Argu::Errors::Unauthorized.new(message: I18n.t('please_login')))
  end

  def create_execute
    response.headers['location'] = token_creator.location
    token_creator.create!
  rescue ActiveRecord::ActiveRecordError
    false
  end

  def create_failure
    respond_with_invalid_resource(resource: token_creator)
  end

  def create_success
    respond_with_new_resource(resource: token_creator.tokens)
  end

  def create_user
    return unless resource_by_secret&.active? && resource_by_secret&.email
    new_user = api.create_user(resource_by_secret.email, r: resource_by_secret.redirect_url)
    return if new_user.blank?
    @new_authorization = api.instance_variable_get(:@user_token)
    @current_user = new_user
  end

  def destroy_execute
    resource_by_secret.update(retracted_at: Time.current)
  end

  def group_id
    @group_id ||= action_name == 'create' ? token_creator.group_id : resource_by_secret!.group_id
  end

  def handle_inactive_token
    active_response_block do
      if api.user_is_group_member?(group_id)
        redirect_already_member
      elsif active_response_type == :html
        redirect_inactive_token
      else
        raise ActiveRecord::RecordNotFound
      end
    end
  end

  def handle_unauthorized_html(_e)
    return super unless action_name == 'show'
    if authorize_redirect_resource
      redirect_to_authorized_r
    else
      redirect_to argu_url('/users/sign_in', r: @_request.env['REQUEST_URI']), notice: I18n.t('please_login')
    end
  end

  def permit_params
    params.require(:data).require(:attributes).permit(%i[redirect_url])
  end

  def redirect_already_member
    respond_with_redirect(location: resource_by_secret.redirect_url || argu_url, notice: I18n.t('already_member'))
  end

  def redirect_inactive_token
    respond_with_redirect(location: argu_url('/token', token: params[:secret], error: 'inactive'))
  end

  def redirect_to_authorized_r
    cookies[:token] = resource_by_secret.iri if resource_by_secret.active?
    redirect_to resource_by_secret.redirect_url, notice: resource_by_secret.active? ? I18n.t('please_login') : nil
  end

  def redirect_location
    current_resource.iri_path
  end

  def redirect_wrong_email
    active_response_block do
      location = if active_response_type == :html
                   argu_url('/users/wrong_email', r: resource_by_secret.iri, email: resource_by_secret.email)
                 else
                   "#{resource_by_secret.iri}/email_conflict"
                 end
      respond_with_redirect(location: location)
    end
  end

  def resource_by_secret
    @resource ||= Token.find_by(secret: params[:secret])
  end
  alias requested_resource resource_by_secret

  def resource_by_secret!
    resource_by_secret || raise(ActiveRecord::RecordNotFound)
  end

  def respond_with_redirect(opts)
    response.headers['New-Authorization'] = @new_authorization if @new_authorization
    super
  end

  def show_execute
    request.head? ? true : token_executor.execute!
  end

  def show_success
    if request.head?
      head 200
    else
      respond_with_redirect(location: token_executor.redirect_url, notice: token_executor.notice(cookies[:locale]))
    end
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

  def token_active?
    resource_by_secret!.active?
  end

  def update_execute
    resource_by_secret.update(permit_params)
  end

  def valid_email?
    request.head? ? true : resource_by_secret.valid_email?(current_user)
  end
end
