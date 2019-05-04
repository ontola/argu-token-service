# frozen_string_literal: true

class BearerToken < Token
  enhance Createable
  enhance Destroyable
  enhance Actionable

  with_columns settings: [
    NS::ARGU[:applyLink],
    NS::ARGU[:redirectUrl],
    NS::ARGU[:usages],
    NS::ARGU[:destroyAction]
  ]

  def valid_email?(_user)
    true
  end
end
