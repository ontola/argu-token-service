# frozen_string_literal: true

class TokenSerializer < RecordSerializer
  include UriTemplateHelper

  attribute :usages, predicate: NS::ARGU[:usages]
  attribute :retracted_at, predicate: NS::ARGU[:retractedAt]
  attribute :expires_at, predicate: NS::ARGU[:expiresAt]
  attribute :group_id, predicate: NS::ARGU[:groupId]
  attribute :message, predicate: NS::ARGU[:message]
  attribute :root_id, predicate: NS::ARGU[:rootId], datatype: NS::XSD[:string]
  attribute :token_url, predicate: NS::ARGU[:applyLink], if: :token_url?
  attribute :redirect_url, predicate: NS::ARGU[:redirectUrl]
  attribute :label, predicate: NS::SCHEMA[:name]
  attribute :description, predicate: NS::SCHEMA[:text]
  attribute :login_action, predicate: NS::ONTOLA[:favoriteAction], if: :login_action?

  triples :accept_action_triples

  link(:self) { object.iri }

  def accept_action_triples # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    return [] unless accept_action?
    entry_point = RDF::URI("#{accept_action}#entryPoint")
    [
      [object.iri, NS::ONTOLA[:favoriteAction], accept_action],
      [accept_action, ::RDF[:type], NS::SCHEMA[:Action]],
      [accept_action, NS::SCHEMA[:name], I18n.t('tokens.invitation.accept_button')],
      [accept_action, NS::SCHEMA[:object], object.iri],
      [accept_action, NS::SCHEMA[:target], entry_point],
      [entry_point, ::RDF[:type], NS::SCHEMA[:EntryPoint]],
      [entry_point, NS::SCHEMA[:name], I18n.t('tokens.invitation.accept_button')],
      [entry_point, NS::SCHEMA[:image], RDF::URI('http://fontawesome.io/icon/check')],
      [entry_point, NS::SCHEMA[:httpMethod], 'POST'],
      [entry_point, NS::SCHEMA[:url], object.iri]
    ]
  end

  def accept_action
    RDF::URI("#{object.iri}/accept")
  end

  def accept_action?
    !guest?
  end

  def display_name; end

  def description
    I18n.t("tokens.invitation.#{guest? ? 'login' : 'accept'}", group: object.group.display_name)
  end

  def label
    I18n.t('tokens.invitation.label')
  end

  def login_action
    RDF::URI("https://#{ActsAsTenant.current_tenant.iri_prefix}/u/sign_in")
  end

  def login_action?
    guest?
  end

  def redirect_url
    RDF::URI(object.redirect_url) if object.redirect_url
  end

  def token_url
    RDF::DynamicURI(expand_uri_template(:tokens_iri, secret: object.secret, with_hostname: true))
  end

  def token_url?
    service_scope? || object.email.blank?
  end
end
