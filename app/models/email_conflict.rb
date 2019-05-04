# frozen_string_literal: true

class EmailConflict
  include ActiveModel::Model
  include ActiveModel::Serialization
  include RailsLD::Model
  include UrlHelper

  attr_accessor :api, :token

  def couple_action_triples # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    return [] if token.account_exists?(api)

    action_iri = ::RDF::DynamicURI("#{iri}/actions/couple_email")
    entry_point_iri = action_iri.dup
    entry_point_iri.fragment = :entrypoint
    form_iri = iri.dup
    form_iri.fragment = :form

    [
      [iri, NS::SCHEMA[:potentialAction], action_iri],
      [iri, NS::ARGU[:favoriteAction], action_iri],
      [action_iri, RDF[:type], NS::SCHEMA[:Action]],
      [action_iri, NS::SCHEMA[:name], I18n.t('email_conflicts.add', email: token.email)],
      [action_iri, NS::SCHEMA[:target], entry_point_iri],
      [action_iri, NS::SCHEMA[:object], token.iri],
      [action_iri, NS::ARGU[:favoriteAction], true],
      [entry_point_iri, RDF[:type], NS::SCHEMA[:EntryPoint]],
      [entry_point_iri, NS::SCHEMA[:name], I18n.t('email_conflicts.add', email: token.email)],
      [entry_point_iri, NS::SCHEMA[:url], RDF::DynamicURI(iri)],
      [entry_point_iri, NS::SCHEMA[:httpMethod], 'PUT']
    ]
  end

  def description
    base = I18n.t('email_conflicts.description', email: token.email)
    if token.account_exists?(api)
      [base, I18n.t('email_conflicts.account_exists', email: token.email)].join("\n\n")
    else
      [base, I18n.t('email_conflicts.link_or_logout', email: token.email)].join("\n\n")
    end
  end

  def label
    I18n.t('email_conflicts.title')
  end

  def logout_action_triples # rubocop:disable Metrics/AbcSize
    action_iri = RDF::DynamicURI("#{iri}/actions/sign_out")
    label = I18n.t("email_conflicts.#{token.account_exists?(api) ? :switch : :create_new_account}")

    [
      [iri, NS::SCHEMA[:potentialAction], action_iri],
      [iri, NS::ARGU[:favoriteAction], action_iri],
      [action_iri, RDF[:type], RDF::DynamicURI(argu_url('/AppSignOut'))],
      [action_iri, NS::SCHEMA[:name], label],
      [action_iri, NS::SCHEMA[:url], token.login_iri]
    ]
  end

  def update(_attrs = {})
    api.couple_email(token.email)
  end

  def iri_opts
    {parent_iri: token.iri_path}
  end

  private

  def couple_email_entry_iri
    @couple_email_entry_iri ||= ::RDF::DynamicURI("#{iri}/actions/couple_email#entrypoint")
  end
end
