# frozen_string_literal: true

class EmailTokenSerializer < TokenSerializer
  class << self
    def accept_action?(object, params)
      return false if object.new_record?

      if guest?(object, params)
        !object.account_exists?(params[:scope].api)
      else
        object.valid_email?(params[:scope].user)
      end
    end

    def login_action?(object, params)
      object.persisted? && guest?(object, params) && object.account_exists?(params[:scope].api)
    end
  end

  attribute :creator, predicate: NS.schema.creator, if: method(:never)
  attribute :email, predicate: NS.argu[:email], if: method(:service_scope?)
  attribute :clicked, predicate: NS.argu[:clicked] do |object|
    object.emails&.first&.clicked? || false
  end
  attribute :invitee, predicate: NS.argu[:invitee]
  attribute :opened, predicate: NS.argu[:opened] do |object|
    object.emails&.first&.opened? || false
  end
  attribute :status, predicate: NS.argu[:status] do |object|
    object.emails&.first&.status
  end
  attribute :send_mail, predicate: NS.argu[:sendMail], datatype: NS.xsd.boolean
  attribute :description, predicate: NS.schema.text do |object, params|
    if object.new_record?
      nil
    elsif guest?(object, params)
      I18n.t(
        "email_tokens.invitation.#{object.account_exists?(params[:scope].api) ? 'login' : 'accept'}",
        group: object.group.display_name,
        email: object.email
      )
    else
      I18n.t('tokens.invitation.accept', group: object.group.display_name)
    end
  end
  attribute :login_iri, predicate: NS.ontola[:favoriteAction], if: method(:login_action?)
end
