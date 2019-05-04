# frozen_string_literal: true

class EmailTokenSerializer < TokenSerializer
  attribute :addresses, predicate: NS::ARGU[:emailAddresses], datatype: NS::XSD[:string], if: :never
  attribute :creator, predicate: NS::SCHEMA[:creator], if: :never
  attribute :email, predicate: NS::ARGU[:email], if: :service_scope?
  attribute :actor_iri, predicate: NS::ARGU[:actorIRI]
  attribute :clicked, predicate: NS::ARGU[:clicked]
  attribute :invitee, predicate: NS::ARGU[:invitee]
  attribute :opened, predicate: NS::ARGU[:opened]
  attribute :status, predicate: NS::ARGU[:status]
  attribute :send_mail, predicate: NS::ARGU[:sendMail], datatype: NS::XSD[:boolean], if: :service_scope?

  def accept_action?
    return false if service_scope?

    if guest?
      !object.account_exists?(scope.api)
    else
      object.valid_email?(scope.user)
    end
  end

  def clicked
    object.emails&.first&.clicked? || false
  end

  def description
    return super unless guest?

    I18n.t(
      "email_tokens.invitation.#{object.account_exists?(scope.api) ? 'login' : 'accept'}",
      group: object.group.display_name,
      email: object.email
    )
  end

  def login_action?
    guest? && object.account_exists?(scope.api)
  end

  def opened
    object.emails&.first&.opened? || false
  end

  def status
    object.emails&.first&.status
  end
end
