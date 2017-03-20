# frozen_string_literal: true
class TokenSerializer < ActiveModel::Serializer
  attributes :id, :usages, :created_at, :expires_at, :retracted_at, :email, :send_mail, :group_id, :opened, :status

  link(:self) { object.context_id }

  def opened
    object.emails&.first&.opened? || false
  end

  def status
    object.emails&.first&.status
  end
end
