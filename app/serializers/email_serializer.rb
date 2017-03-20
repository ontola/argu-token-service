# frozen_string_literal: true
class EmailSerializer < ActiveModel::Serializer
  delegate :id, to: :object

  has_many :email_events do
    object.email_events
  end
end
