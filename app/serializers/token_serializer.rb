# frozen_string_literal: true

class TokenSerializer < RecordSerializer
  extend UriTemplateHelper
  class << self
    def accept_action_triples(object, params) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      return [] unless accept_action?(object, params)

      accept_action = RDF::URI("#{object.iri}/accept")
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

    def accept_action?(object, params)
      !guest?(object, params)
    end

    def login_action?(object, params)
      guest?(object, params)
    end

    def token_url?(object, params)
      service_scope?(object, params) || object.email.blank?
    end
  end

  attribute :actor_iri, predicate: NS::ARGU[:actorIRI] do |object|
    RDF::URI(object.actor_iri) if object.is_a?(EmailToken)
  end
  attribute :usages, predicate: NS::ARGU[:usages]
  attribute :retracted_at, predicate: NS::ARGU[:retractedAt]
  attribute :expires_at, predicate: NS::ARGU[:expiresAt]
  attribute :group_id, predicate: NS::ARGU[:groupId]
  attribute :message, predicate: NS::ARGU[:message]
  attribute :root_id, predicate: NS::ARGU[:rootId], datatype: NS::XSD[:string]
  attribute :token_url, predicate: NS::ARGU[:applyLink], if: method(:token_url?) do |object|
    RDF::DynamicURI(expand_uri_template(:tokens_iri, secret: object.secret, with_hostname: true))
  end
  attribute :redirect_url, predicate: NS::ARGU[:redirectUrl] do |object|
    RDF::URI(object.redirect_url) if object.redirect_url
  end
  attribute :label, predicate: NS::SCHEMA[:name] do
    I18n.t('tokens.invitation.label')
  end
  attribute :description, predicate: NS::SCHEMA[:text] do |object, params|
    I18n.t("tokens.invitation.#{guest?(object, params) ? 'login' : 'accept'}", group: object.group.display_name)
  end
  attribute :login_action, predicate: NS::ONTOLA[:favoriteAction], if: method(:login_action?) do
    RDF::URI("https://#{ActsAsTenant.current_tenant.iri_prefix}/u/sign_in")
  end
  attribute :addresses, predicate: NS::ARGU[:emailAddresses], datatype: NS::XSD[:string], if: method(:never)
  attribute :send_mail, predicate: NS::ARGU[:sendMail], datatype: NS::XSD[:boolean], if: method(:never)

  statements :accept_action_triples
end
