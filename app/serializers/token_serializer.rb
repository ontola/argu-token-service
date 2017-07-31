# frozen_string_literal: true
class TokenSerializer < ActiveModel::Serializer
  def service_scope?
    scope&.doorkeeper_scopes&.include? 'service'
  end
  attributes %i(id usages created_at expires_at retracted_at invitee
                send_mail group_id opened status message actor_iri)
  attribute :email, if: :service_scope?

  link(:self) { object.context_id }

  def opened
    object.emails&.first&.opened? || false
  end

  def status
    object.emails&.first&.status
  end
end
