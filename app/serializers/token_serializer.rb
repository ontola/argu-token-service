# frozen_string_literal: true

class TokenSerializer < RecordSerializer
  include UriTemplateHelper

  attribute :usages, predicate: NS::ARGU[:usages]
  attribute :retracted_at, predicate: NS::ARGU[:retractedAt]
  attribute :invitee, predicate: NS::ARGU[:invitee]
  attribute :send_mail, predicate: NS::ARGU[:sendMail]
  attribute :group_id, predicate: NS::ARGU[:groupId]
  attribute :opened, predicate: NS::ARGU[:opened]
  attribute :status, predicate: NS::ARGU[:status]
  attribute :message, predicate: NS::ARGU[:message]
  attribute :actor_iri, predicate: NS::ARGU[:actorIri]
  attribute :clicked, predicate: NS::ARGU[:clicked]
  attribute :root_id, predicate: NS::ARGU[:rootId]
  attribute :email, predicate: NS::ARGU[:email], if: :service_scope?
  attribute :token_url, predicate: NS::ARGU[:applyLink], if: :token_url?

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
    RDF::URI(expand_uri_template(:tokens_iri, secret: object.secret, with_hostname: true))
  end

  def token_url?
    service_scope? || object.email.blank?
  end
end
