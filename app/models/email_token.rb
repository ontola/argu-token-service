# frozen_string_literal: true

class EmailToken < Token
  enhance LinkedRails::Enhancements::Creatable
  enhance LinkedRails::Enhancements::Destroyable
  collection_options(
    title: -> { I18n.t('email_tokens.plural') }
  )
  with_columns settings: [
    NS.argu[:invitee],
    NS.ontola[:redirectUrl],
    NS.argu[:opened],
    NS.ontola[:updateAction],
    NS.ontola[:destroyAction]
  ]
  after_create :send_invite_mail

  def account_exists?(api)
    @account_exists ||= api.email_address_exists?(email)
  end

  def addresses; end

  def email
    super&.downcase
  end

  def emails
    return [] if id.nil? || previous_changes['id']&.first.nil? && previous_changes['id']&.second.present?

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

  private

  def send_invite_mail
    SendEmailWorker.perform_async(
      :email_token_created,
      email,
      {
        iri: iri,
        message: message,
        group_id: group_id,
        actor_iri: actor_iri
      }
    )
  end

  class << self
    def attributes_for_new(opts = {})
      super_opts = super

      super_opts.merge(
        message: I18n.t(
          'email_tokens.form.message.default_message',
          group: super_opts[:group].display_name
        ),
        send_mail: true
      )
    end

    def route_key
      :email
    end
  end
end
