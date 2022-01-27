# frozen_string_literal: true

class EmailConflict
  include ActiveModel::Model
  include ActiveModel::Serialization
  include LinkedRails::Model
  include URITemplateHelper
  include UrlHelper
  enhance LinkedRails::Enhancements::Updatable

  attr_accessor :api, :token

  def couple_action_triples # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    return [] if token.account_exists?(api)

    action_iri = ::RDF::URI("#{iri}/actions/couple_email")
    entry_point_iri = action_iri.dup
    entry_point_iri.fragment = :entrypoint
    form_iri = iri.dup
    form_iri.fragment = :form

    [
      [iri, NS.schema.potentialAction, action_iri],
      [iri, NS.ontola[:favoriteAction], action_iri],
      [action_iri, RDF[:type], NS.schema.Action],
      [action_iri, NS.schema.isPartOf, iri],
      [action_iri, NS.schema.name, I18n.t('email_conflicts.add', email: token.email)],
      [action_iri, NS.schema.target, entry_point_iri],
      [action_iri, NS.schema.object, token.iri],
      [action_iri, NS.ontola[:favoriteAction], true],
      [entry_point_iri, RDF[:type], NS.schema.EntryPoint],
      [entry_point_iri, NS.schema.isPartOf, action_iri],
      [entry_point_iri, NS.schema.name, I18n.t('email_conflicts.add', email: token.email)],
      [entry_point_iri, NS.schema.url, RDF::URI(iri)],
      [entry_point_iri, NS.schema.httpMethod, 'PUT']
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
    action_iri = RDF::URI("#{iri}/actions/sign_out")
    label = I18n.t("email_conflicts.#{token.account_exists?(api) ? :switch : :create_new_account}")

    [
      [iri, NS.schema.potentialAction, action_iri],
      [iri, NS.ontola[:favoriteAction], action_iri],
      [action_iri, RDF[:type], RDF::DynamicURI(argu_url('/AppSignOut'))],
      [action_iri, NS.schema.name, label],
      [action_iri, NS.schema.url, token.login_iri]
    ]
  end

  def update(_attrs = {})
    api.couple_email(token.email)
  end

  def iri_opts
    {parent_iri: split_iri_segments(token.root_relative_iri)}
  end

  private

  def couple_email_entry_iri
    @couple_email_entry_iri ||= ::RDF::URI("#{iri}/actions/couple_email#entrypoint")
  end

  class << self
    def iri_template
      @iri_template ||= LinkedRails::URITemplate.new('{/parent_iri*}/email_conflict')
    end

    def requested_singular_resource(params, user_context)
      token = LinkedRails.iri_mapper.parent_from_params(params, user_context)

      new(api: user_context.api, token: token)
    end

    def singular_route_key
      :email_conflict
    end
  end
end
