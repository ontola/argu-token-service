# frozen_string_literal: true

class EmailToken < Token
  enhance Createable
  enhance Destroyable
  enhance Actionable

  with_columns settings: [
    NS::ARGU[:invitee],
    NS::ARGU[:redirectUrl],
    NS::ARGU[:opened],
    NS::ARGU[:destroyAction]
  ]
end
