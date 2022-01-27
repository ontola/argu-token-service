# frozen_string_literal: true

class TokenSerializer < RecordSerializer
  extend URITemplateHelper
  class << self
    def accept_action_triples(object, params) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      return [] unless accept_action?(object, params)

      accept_action = RDF::URI("#{object.iri}/accept")
      entry_point = RDF::URI("#{accept_action}#entryPoint")
      [
        [object.iri, NS.ontola[:favoriteAction], accept_action],
        [accept_action, ::RDF[:type], NS.schema.Action],
        [accept_action, NS.schema.isPartOf, object.iri],
        [accept_action, NS.schema.name, I18n.t('tokens.invitation.accept_button')],
        [accept_action, NS.schema.object, object.iri],
        [accept_action, NS.schema.target, entry_point],
        [entry_point, ::RDF[:type], NS.schema.EntryPoint],
        [entry_point, NS.schema.name, I18n.t('tokens.invitation.accept_button')],
        [entry_point, NS.schema.isPartOf, accept_action],
        [entry_point, NS.schema.image, RDF::URI('http://fontawesome.io/icon/check')],
        [entry_point, NS.schema.httpMethod, 'POST'],
        [entry_point, NS.schema.url, object.iri]
      ]
    end

    def accept_action?(object, params)
      !guest?(object, params) && object.persisted?
    end

    def login_action?(object, params)
      guest?(object, params) && object.persisted?
    end

    def token_url?(object, params)
      service_scope?(object, params) || object.email.blank?
    end
  end

  attribute :actor_iri, predicate: NS.argu[:actorIRI] do |object|
    RDF::URI(object.actor_iri) if object.is_a?(EmailToken) && object.actor_iri
  end
  attribute :usages, predicate: NS.argu[:usages]
  attribute :max_usages, predicate: NS.argu[:maxUsages]
  attribute :retracted_at, predicate: NS.argu[:retractedAt]
  attribute :expires_at, predicate: NS.argu[:expiresAt]
  attribute :group_id, predicate: NS.argu[:groupId]
  attribute :message, predicate: NS.argu[:message]
  attribute :root_id, predicate: NS.argu[:rootId], datatype: NS.xsd.string
  attribute :token_url, predicate: NS.argu[:applyLink], if: method(:token_url?) do |object|
    LinkedRails.iri(path: Token.iri_template.expand(id: object.secret))
  end
  attribute :redirect_url, predicate: NS.ontola[:redirectUrl] do |object|
    RDF::URI(object.redirect_url) if object.redirect_url
  end
  attribute :label, predicate: NS.schema.name do
    I18n.t('tokens.invitation.label')
  end
  attribute :description, predicate: NS.schema.text do |object, params|
    I18n.t("tokens.invitation.#{guest?(object, params) ? 'login' : 'accept'}", group: object.group.display_name)
  end
  attribute :login_iri, predicate: NS.ontola[:favoriteAction], if: method(:login_action?)
  attribute :addresses, predicate: NS.argu[:emailAddresses], datatype: NS.xsd.string, if: method(:never)
  attribute :send_mail, predicate: NS.argu[:sendMail], datatype: NS.xsd.boolean, if: method(:never)

  statements :accept_action_triples
end
