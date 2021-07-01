# frozen_string_literal: true

class BearerToken < Token
  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Destroyable
  enhance LinkedRails::Enhancements::Actionable

  with_columns settings: [
    NS.argu[:applyLink],
    NS.ontola[:redirectUrl],
    NS.argu[:usages],
    NS.ontola[:destroyAction]
  ]

  def valid_email?(_user)
    true
  end

  class << self
    def route_key
      :bearer
    end
  end
end
