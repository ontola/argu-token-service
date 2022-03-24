# frozen_string_literal: true

class BearerToken < Token
  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Destroyable
  collection_options(
    include_members: true,
    title: -> { I18n.t('bearer_tokens.plural') }
  )
  with_columns settings: [
    NS.argu[:applyLink],
    NS.ontola[:redirectUrl],
    NS.argu[:usages],
    NS.argu[:expiresAt],
    NS.ontola[:updateAction],
    NS.ontola[:destroyAction]
  ]

  def valid_email?(_user)
    true
  end

  class << self
    def attributes_for_new(opts)
      attrs = super
      attrs[:max_usages] ||= 1
      attrs[:expires_at] ||= 1.week.from_now
      attrs
    end

    def route_key
      :bearer
    end
  end
end
