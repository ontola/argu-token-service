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

  def account_exists?(api)
    @account_exists ||= api.email_address_exists?(email)
  end

  def email
    super&.downcase
  end

  def emails
    return [] if previous_changes['id']&.first.nil? && previous_changes['id']&.second.present?
    @emails ||= Email.where(
      resource_id: id,
      resource_type: 'tokens',
      event: 'create'
    )
  end

  def valid_email?(user)
    user.email_addresses.map { |e| e.attributes['email'] }.include?(email)
  end
end
