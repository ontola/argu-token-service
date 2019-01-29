# frozen_string_literal: true

class TokenSerializer < RecordSerializer
  include UriTemplateHelper

  attribute :usages, predicate: NS::ARGU[:usages]
  attribute :retracted_at, predicate: NS::ARGU[:retractedAt]
  attribute :group_id, predicate: NS::ARGU[:groupId]
  attribute :message, predicate: NS::ARGU[:message]
  attribute :root_id, predicate: NS::ARGU[:rootId], datatype: NS::XSD[:string]
  attribute :token_url, predicate: NS::ARGU[:applyLink], if: :token_url?
  attribute :redirect_url, predicate: NS::ARGU[:redirectUrl]

  # @todo EmailToken only
  attribute :email, predicate: NS::ARGU[:email], if: :service_scope?
  attribute :actor_iri, predicate: NS::ARGU[:actorIRI]
  attribute :clicked, predicate: NS::ARGU[:clicked]
  attribute :invitee, predicate: NS::ARGU[:invitee]
  attribute :opened, predicate: NS::ARGU[:opened]
  attribute :status, predicate: NS::ARGU[:status]
  attribute :creator, predicate: NS::SCHEMA[:creator], if: :never
  attribute :addresses, predicate: NS::ARGU[:emailAddresses], datatype: NS::XSD[:string], if: :never
  attribute :send_mail, predicate: NS::ARGU[:sendMail], datatype: NS::XSD[:boolean], if: :service_scope?

  link(:self) { object.iri }

  def clicked
    object.emails&.first&.clicked? || false
  end

  def display_name; end

  def opened
    object.emails&.first&.opened? || false
  end

  def status
    object.emails&.first&.status
  end

  def token_url
    RDF::DynamicURI(expand_uri_template(:tokens_iri, secret: object.secret, with_hostname: true))
  end

  def token_url?
    service_scope? || object.email.blank?
  end
end
