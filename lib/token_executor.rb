# frozen_string_literal: true
class TokenExecutor
  include UrlHelper, JsonApiHelper, UriTemplateHelper
  attr_accessor :token, :user, :argu_token

  def initialize(token: nil, user: nil, argu_token: nil)
    self.token = token
    self.user = user
    self.argu_token = argu_token
  end

  def execute!
    post_membership
  end

  def notice(locale)
    return unless @membership_request.status == 201
    I18n.t('group_memberships.welcome', group: group_name(@membership_request), locale: locale)
  end

  def redirect_url
    token.redirect_url || @membership_request&.headers.try(:[], :location) || argu_url
  end

  def authorize_redirect_resource
    return unless token.redirect_url.present?
    authorize_url = uri_template(:spi_authorize).expand(
      resource_iri: token.redirect_url,
      authorize_action: :show
    )
    argu_token.get(authorize_url).status == 200
  rescue OAuth2::Error
    false
  end

  private

  def group_name(request)
    json_api_included_resource(
      JSON.parse(request.body),
      id: JSON.parse(request.body)['data']['relationships']['group']['data']['id'],
      type: 'groups'
    )[:attributes][:name]
  end

  def post_membership
    @membership_request = token.post_membership(argu_token, user)
    token.update_usage! if @membership_request.status == 201
  end
end
