# frozen_string_literal: true
class TokenSerializer < ActiveModel::Serializer
  attributes :id, :usages, :created_at, :expires_at, :retracted_at, :email, :send_mail, :group_id

  link(:self) { object.context_id }
end
