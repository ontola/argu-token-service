# frozen_string_literal: true

require 'token_creator'
require 'token_executor'

class TokensController < ApplicationController # rubocop:disable Metrics/ClassLength
  include ActionController::Helpers
  include ActionController::Flash
  include LinkedRails::Enhancements::Destroyable::Controller
  include UriTemplateHelper
  active_response :show, :update, :create, :destroy

  prepend_before_action :handle_inactive_token, only: :show, unless: :token_active?
  before_action :redirect_wrong_email, unless: :valid_email?, only: %i[show]

  private

  def actor_iri
    @actor_iri ||= params.key?(:actor_iri) ? params.require(:actor_iri) : permit_params[:actor_iri]
  rescue ActionController::ParameterMissing
    nil
  end

  def attribute_params
    @attribute_params ||=
      if request.format.json_api?
        params.require(:data).require(:attributes)
      else
        params.require(controller_name.singularize)
      end
  end

  def authorize_redirect_resource
    api.authorize_redirect_resource(resource_by_secret)
  end

  def check_if_registered
    return super unless action_name == 'show'
    return current_user unless execute_token?

    !current_user.guest? || create_user || handle_not_logged_in
  end

  def create_execute
    token_creator.create!
  rescue ActiveRecord::ActiveRecordError
    false
  end

  def create_failure
    respond_with_invalid_resource(resource: token_creator)
  end

  def create_success
    respond_with_new_resource(create_success_options_rdf.merge(resource: token_creator.tokens))
  end

  def create_success_location
    settings_iri(Group.new(id: group_id).iri_path, fragment: :"#{token_type}_invite").to_s
  end
  alias destroy_success_location create_success_location

  def create_user
    return unless resource_by_secret&.active? && resource_by_secret&.email

    @current_user = api.create_user(
      resource_by_secret.email,
      headers: response.headers,
      redirect: resource_by_secret.redirect_url
    )
  end

  def destroy_execute
    resource_by_secret.update(retracted_at: Time.current)
  end

  def execute_token?
    @execute_token ||= request.post?
  end

  def group_id
    @group_id ||= parse_group_id(
      case action_name
      when 'create'
        params.key?(:group_id) ? params.require(:group_id) : attribute_params.require(:group_id)
      when 'index'
        params[:group_id]
      else
        resource_by_secret!.group_id
      end
    )
  end

  def handle_inactive_token
    active_response_block do
      if !current_user.guest? && api.user_is_group_member?(group_id)
        redirect_already_member
      elsif authorize_redirect_resource
        redirect_to_authorized_r
      else
        raise ActiveRecord::RecordNotFound
      end
    end
  end

  def handle_not_logged_in
    active_response_block do
      respond_with_resource(
        resource: resource_by_secret!,
        fields: {bearerTokens: %i[label description login_action type]}
      )
    end
  end

  def new_resource
    controller_class.new(new_resource_params)
  end

  def new_resource_params
    {
      actor_iri: actor_iri,
      group_id: group_id,
      root_id: tree_root.uuid
    }
  end

  def parent_resource
    @parent_resource ||= Group.new(id: group_id)
  end

  def parent_resource!
    parent_resource || raise(ActiveRecord::RecordNotFound)
  end

  def parse_group_id(group_id)
    return group_id unless group_id.to_s.include?(Rails.application.config.frontend_url)

    path = group_id.gsub(Rails.application.config.frontend_url, '')
    uri_template(:groups_iri).extract(path)['id']
  end

  def permit_params
    @permit_params ||=
      attribute_params
        .permit(%i[actor_iri expires_at group_id root_id message redirect_url send_mail addresses] + [addresses: []])
  end

  def r_for_guest_token
    resource_by_secret&.redirect_url || super
  end

  def redirect_after_execute
    respond_with_redirect(
      location: token_executor.redirect_url,
      notice: token_executor.notice,
      reload: true
    )
  end

  def redirect_already_member
    respond_with_redirect(
      location: resource_by_secret.redirect_url || argu_url("/#{tree_root.url}"),
      notice: I18n.t('already_member')
    )
  end

  def redirect_to_authorized_r
    redirect_to resource_by_secret.redirect_url, notice: resource_by_secret.active? ? I18n.t('please_login') : nil
  end

  def redirect_location
    current_resource.iri_path
  end

  def redirect_wrong_email
    active_response_block do
      respond_with_redirect(location: wrong_email_location)
    end
  end

  def resource_by_secret
    @resource_by_secret ||= Token.find_by(secret: params[:secret])
  end
  alias requested_resource resource_by_secret

  def resource_by_secret!
    resource_by_secret || raise(ActiveRecord::RecordNotFound)
  end

  def show_execute
    execute_token? ? token_executor.execute! : true
  end

  def show_success
    return redirect_after_execute if execute_token?

    respond_with_resource(
      resource: resource_by_secret,
      fields: {bearerTokens: %i[label description login_action type]}
    )
  end

  def token_creator
    if request.format.json_api? && !%w[bearerToken emailTokenRequest].include?(params.require(:data)[:type])
      raise ActionController::UnpermittedParameters.new(%w[type])
    end

    @token_creator ||= TokenCreator.new(actor_iri, group_id, params: permit_params)
  end

  def token_executor(user = current_user)
    @token_executor ||= TokenExecutor.new(token: resource_by_secret!, user: user, api: api)
  end

  def token_active?
    resource_by_secret!.active?
  end

  def token_type
    @token_type ||= resource_by_secret&.type&.gsub('Token', '')&.underscore || token_creator.type
  end

  def update_execute
    resource_by_secret.update(permit_params)
  end

  def valid_email?
    current_user.guest? || resource_by_secret.valid_email?(current_user)
  end

  def wrong_email_location
    "#{resource_by_secret.iri}/email_conflict"
  end
end
