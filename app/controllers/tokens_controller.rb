# frozen_string_literal: true

require 'token_creator'
require 'token_executor'

class TokensController < ApplicationController # rubocop:disable Metrics/ClassLength
  include ActionController::Helpers
  include ActionController::Flash
  include UriTemplateHelper
  active_response :show, :update, :create, :destroy, :accept

  prepend_before_action :handle_inactive_token, only: %i[accept show], unless: :token_active?
  before_action :redirect_wrong_email, unless: :valid_email?, only: %i[accept show]

  private

  def accept_execute
    token_executor.execute!
  end

  def accept_success
    respond_with_redirect(
      location: token_executor.redirect_url,
      notice: token_executor.notice,
      reload: true
    )
  end

  def actor_iri
    @actor_iri ||= params.key?(:actor_iri) ? params.require(:actor_iri) : permit_params[:actor_iri]
  rescue ActionController::ParameterMissing
    nil
  end

  def attribute_params
    @attribute_params ||= params.require(controller_name.singularize)
  end

  def authorize_redirect_resource
    api.authorize_redirect_resource(current_resource)
  end

  def check_if_registered
    return current_user if action_name == 'show'
    return super unless action_name == 'accept' && current_resource.email?

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
    settings_iri(Group.new(id: current_resource!.group_id).root_relative_iri, fragment: :"#{token_type}_invite").to_s
  end
  alias destroy_success_location create_success_location

  def create_user
    return unless current_resource&.active? && current_resource&.email

    @current_user = api.create_user(
      current_resource.email,
      headers: response.headers,
      redirect: current_resource.redirect_url
    )
  end

  def destroy_execute
    current_resource.update!(retracted_at: Time.current)
  end

  def handle_inactive_token
    active_response_block do
      if !current_user.guest? && api.user_is_group_member?(current_resource!.group_id)
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
        resource: current_resource!,
        fields: {bearerTokens: %i[label description login_action type]}
      )
    end
  end

  def index_association; end

  def new_resource
    controller_class.new(new_resource_params)
  end

  def new_resource_params
    {
      actor_iri: actor_iri,
      group_id: parent_resource.id,
      root_id: tree_root.uuid
    }
  end

  def parent_resource
    super || parent_from_iri
  end

  def parent_from_iri
    Group.new(id: parse_group_id(permit_params.require(:group_id)))
  end

  def parse_group_id(group_id)
    return group_id unless group_id.to_s.include?(LinkedRails.iri.to_s)

    path = group_id.gsub(LinkedRails.iri.to_s, '')
    uri_template(:groups_iri).extract(path)['id']
  end

  def permit_params
    @permit_params ||=
      attribute_params
        .permit(%i[actor_iri expires_at group_id root_id message redirect_url send_mail addresses] + [addresses: []])
  end

  def r_for_guest_token
    current_resource&.redirect_url || super if @current_resource
  end

  def redirect_already_member
    respond_with_redirect(
      location: current_resource.redirect_url || argu_url("/#{tree_root.url}"),
      notice: I18n.t('already_member')
    )
  end

  def redirect_to_authorized_r
    redirect_to current_resource.redirect_url, notice: current_resource.active? ? I18n.t('please_login') : nil
  end

  def redirect_location
    current_resource.root_relative_iri.to_s
  end

  def redirect_wrong_email
    active_response_block do
      respond_with_redirect(location: wrong_email_location)
    end
  end

  def current_resource!
    current_resource || raise(ActiveRecord::RecordNotFound)
  end

  def show_success
    respond_with_resource(
      resource: current_resource,
      fields: {bearerTokens: %i[label description login_action type]}
    )
  end

  def token_creator
    @token_creator ||= TokenCreator.new(actor_iri, parent_resource.id, params: permit_params)
  end

  def token_executor(user = current_user)
    @token_executor ||= TokenExecutor.new(token: current_resource!, user: user, api: api)
  end

  def token_active?
    current_resource!.active?
  end

  def token_type
    @token_type ||= current_resource&.type&.gsub('Token', '')&.underscore || token_creator.type
  end

  def update_execute
    current_resource.update(permit_params)
  end

  def valid_email?
    current_user.guest? || current_resource.valid_email?(current_user)
  end

  def wrong_email_location
    "#{current_resource.iri}/email_conflict"
  end
end
