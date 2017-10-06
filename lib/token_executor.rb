# frozen_string_literal: true

class TokenExecutor
  include UriTemplateHelper
  include JsonApiHelper
  include UrlHelper
  attr_accessor :token, :user, :service_token, :user_token

  def initialize(token: nil, user: nil, service_token: nil, user_token: nil)
    self.token = token
    self.user = user
    self.service_token = service_token
    self.user_token = user_token
  end

  def execute!
    post_membership
    confirm_email if token.email
  end

  def notice(locale)
    case @membership_request.status
    when 201
      I18n.t('group_memberships.welcome', group: group_name(@membership_request), locale: locale)
    when 304
      I18n.t('already_member')
    end
  end

  def redirect_url
    token.redirect_url || @membership_request&.headers.try(:[], :location) || argu_url
  end

  def authorize_redirect_resource
    return if token.redirect_url.blank?
    authorize_url = uri_template(:spi_authorize).expand(
      resource_iri: token.redirect_url,
      authorize_action: :show
    )
    user_token.get(authorize_url).status == 200
  rescue OAuth2::Error
    false
  end

  private

  def confirm_email
    email = user.email_addresses.detect { |e| e.attributes['email'] == token.email }
    token.confirm_email(service_token, email) if email.attributes['confirmed_at'].nil?
  end

  def group_name(request)
    json_api_included_resource(
      JSON.parse(request.body),
      id: JSON.parse(request.body)['data']['relationships']['group']['data']['id'],
      type: 'groups'
    )[:attributes][:name]
  end

  def post_membership
    @membership_request = token.post_membership(user_token, user)
    token.update_usage! if @membership_request.status == 201
  end
end
