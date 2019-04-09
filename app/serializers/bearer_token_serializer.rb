# frozen_string_literal: true

class BearerTokenSerializer < TokenSerializer
  attribute :label, predicate: NS::SCHEMA[:name], if: :guest?
  attribute :description, predicate: NS::SCHEMA[:text], if: :guest?
  attribute :login_action, predicate: NS::ARGU[:favoriteAction], if: :guest?

  def description
    I18n.t('bearer_tokens.invitation.description', group: object.group.display_name)
  end

  def label
    I18n.t('bearer_tokens.invitation.label')
  end

  def login_action
    RDF::URI("https://#{ActsAsTenant.current_tenant.iri_prefix}/u/sign_in")
  end
end
