# frozen_string_literal: true

class EmailToken < Token
  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Destroyable
  enhance LinkedRails::Enhancements::Actionable

  with_columns settings: [
    NS::ARGU[:invitee],
    NS::ONTOLA[:redirectUrl],
    NS::ARGU[:opened],
    NS::ONTOLA[:destroyAction]
  ]

  def account_exists?(api)
    @account_exists ||= api.email_address_exists?(email)
  end

  def addresses; end

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

  def parent_collections(user_context)
    [group.email_token_collection(user_context: user_context)]
  end

  def valid_email?(user)
    user.email_addresses.map { |e| e.attributes['email'] }.include?(email)
  end

  class << self
    def attribute_for_new(opts = {})
      super.merge(
        message: I18n.t(
          'email_tokens.form.message.default_message',
          group: opts[:group].display_name
        ),
        send_mail: true
      )
    end
  end
end
