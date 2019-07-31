# frozen_string_literal: true

class BearerToken < Token
  enhance LinkedRails::Enhancements::Createable
  enhance LinkedRails::Enhancements::Destroyable
  enhance LinkedRails::Enhancements::Actionable

  with_columns settings: [
    NS::ARGU[:applyLink],
    NS::ARGU[:redirectUrl],
    NS::ARGU[:usages],
    NS::ONTOLA[:destroyAction]
  ]

  def action_triples
    []
  end

  def valid_email?(_user)
    true
  end
end
