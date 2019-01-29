# frozen_string_literal: true

class TokenExecutor
  include JsonApiHelper
  include UrlHelper
  attr_accessor :token, :user, :api

  def initialize(token: nil, user: nil, api: nil)
    self.token = token
    self.user = user
    self.api = api
  end

  def execute!
    create_membership
    confirm_email if token.email
    create_favorite(token.root_id, token.redirect_url)
    true
  end

  def notice(locale)
    case @membership_request.status
    when 201
      I18n.t('group_memberships.welcome', group: group_name(@membership_request), locale: locale)
    when 304
      I18n.t('already_member')
    end
  end

  def redirect_url # rubocop:disable Metrics/AbcSize
    url = token.redirect_url || @membership_request&.headers.try(:[], :location) || argu_url
    old_frontend = RequestStore.store[:old_frontend]
    RequestStore.store[:old_frontend] = url.to_s.starts_with?("https://#{Rails.application.config.host_name}")
    url = DynamicUriHelper.revert(url, ActsAsTenant.current_tenant)
    RequestStore.store[:old_frontend] = old_frontend
    url
  end

  private

  def confirm_email
    api.confirm_email_address(email_record.attributes['email']) if email_record.attributes['confirmed_at'].nil?
  end

  def create_favorite(root_id, iri)
    api.create_favorite(root_id, iri) if iri
  rescue OAuth2::Error => e
    Bugsnag.notify(e)
  end

  def create_membership
    @membership_request = api.create_membership(token)
    token.update_usage! if @membership_request.status == 201
  end

  def group_name(request)
    json_api_included_resource(
      JSON.parse(request.body),
      id: JSON.parse(request.body)['data']['relationships']['group']['data']['id'],
      type: 'groups'
    )[:attributes][:displayName]
  end

  def email_record
    user.email_addresses.detect { |e| e.attributes['email'] == token.email }
  end
end
