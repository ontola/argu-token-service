# frozen_string_literal: true
class TokenSerializer < ActiveModel::Serializer
  attributes :id, :usages, :created_at, :expires_at, :retracted_at

  link :url do
    [Rails.application.config.host_name, '/tokens/bearer/', object.secret].join
  end
end
