# frozen_string_literal: true

class EmailTokenSerializer < TokenSerializer
  attribute :creator, predicate: NS::SCHEMA[:creator], if: method(:never)
  attribute :email, predicate: NS::ARGU[:email], if: method(:service_scope?)
  attribute :clicked, predicate: NS::ARGU[:clicked] do |object|
    object.emails&.first&.clicked? || false
  end
  attribute :invitee, predicate: NS::ARGU[:invitee]
  attribute :opened, predicate: NS::ARGU[:opened] do |object|
    object.emails&.first&.opened? || false
  end
  attribute :status, predicate: NS::ARGU[:status] do |object|
    object.emails&.first&.status
  end
  attribute :send_mail, predicate: NS::ARGU[:sendMail], datatype: NS::XSD[:boolean]
  attribute :description, predicate: NS::SCHEMA[:text] do |object, params|
    if guest?(object, params)
      I18n.t(
        "email_tokens.invitation.#{object.account_exists?(params[:scope].api) ? 'login' : 'accept'}",
        group: object.group.display_name,
        email: object.email
      )
    else
      I18n.t('tokens.invitation.accept', group: object.group.display_name)
    end
  end

  class << self
    def accept_action?(object, params)
      return false if service_scope?(object, params)

      if guest?(object, params)
        !object.account_exists?(params[:scope].api)
      else
        object.valid_email?(params[:scope].user)
      end
    end

    def login_action?(object, params)
      guest?(object, params) && object.account_exists?(params[:scope].api)
    end
  end
end
