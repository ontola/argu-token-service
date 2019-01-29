# frozen_string_literal: true

require 'token_creator'
require 'token_executor'

class EmailConflictsController < ApplicationController
  before_action :verify_email_conflict

  def show
    respond_to do |format|
      RDF_CONTENT_TYPES.each do |type|
        format.send(type) { render type => email_conflict_graph }
      end
    end
  end

  private

  def account_exists?
    @account_exists ||= api.email_address_exists?(token.email)
  end

  def conflict_description
    base = I18n.t('email_conflicts.description', email: token.email)
    if account_exists?
      [base, I18n.t('email_conflicts.account_exists', email: token.email)].join("\n\n")
    else
      [base, I18n.t('email_conflicts.link_or_logout', email: token.email)].join("\n\n")
    end
  end

  def couple_email_entry_iri
    @couple_email_entry_iri ||= ::RDF::DynamicURI("#{requested_url}/actions/couple_email#entrypoint")
  end

  def email_conflict_graph # rubocop:disable Metrics/AbcSize
    graph = ::RDF::Graph.new
    graph << [::RDF::DynamicURI(requested_url), ::RDF[:type], NS::SCHEMA[:Thing]]
    graph << [::RDF::DynamicURI(requested_url), NS::SCHEMA[:name], I18n.t('email_conflicts.title')]
    graph << [::RDF::DynamicURI(requested_url), NS::SCHEMA[:text], conflict_description]

    add_couple_action(graph) unless account_exists?
    add_logout_action(graph)

    graph
  end

  def add_couple_action(graph) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    iri = ::RDF::DynamicURI("#{requested_url}/actions/couple_email")
    entry_point_iri = iri.dup
    entry_point_iri.fragment = :entrypoint
    form_iri = iri.dup
    form_iri.fragment = :form
    email_property = RDF::Node.new
    email_node = RDF::Node.new

    graph << [::RDF::DynamicURI(requested_url), NS::SCHEMA[:potentialAction], iri]
    graph << [::RDF::DynamicURI(requested_url), NS::ARGU[:favoriteAction], iri]

    graph << [iri, RDF[:type], NS::SCHEMA[:Action]]
    graph << [iri, NS::SCHEMA[:name], I18n.t('email_conflicts.add', email: token.email)]
    graph << [iri, NS::SCHEMA[:target], entry_point_iri]
    graph << [iri, NS::SCHEMA[:object], token.iri]
    graph << [iri, NS::ARGU[:favoriteAction], true]

    graph << [entry_point_iri, RDF[:type], NS::SCHEMA[:EntryPoint]]
    graph << [entry_point_iri, NS::SCHEMA[:name], I18n.t('email_conflicts.add', email: token.email)]
    graph << [entry_point_iri, NS::SCHEMA[:url], RDF::DynamicURI(argu_url('/settings'))]
    graph << [entry_point_iri, NS::SCHEMA[:httpMethod], 'PUT']
    graph << [entry_point_iri, NS::LL[:actionBody], form_iri]

    graph << [form_iri, RDF[:type], NS::SH[:NodeShape]]
    graph << [form_iri, NS::SH[:property], email_property]
    graph << [form_iri, NS::SH[:targetNode], RDF::DynamicURI(current_user.iri)]

    graph << [email_property, RDF[:type], NS::SH[:PropertyShape]]
    graph << [email_property, NS::SH[:path], NS::ARGU[:emails]]
    graph << [email_property, NS::SH[:targetNode], email_node]

    graph << [email_node, RDF[:type], NS::ARGU[:EmailAddress]]
    graph << [email_node, NS::SCHEMA[:email], token.email]
  end

  def add_logout_action(graph) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    iri = ::RDF::DynamicURI("#{requested_url}/actions/logout")
    entry_point_iri = iri.dup
    entry_point_iri.fragment = :entrypoint
    label = I18n.t("email_conflicts.#{account_exists? ? :switch : :create_new_account}")

    graph << [::RDF::DynamicURI(requested_url), NS::SCHEMA[:potentialAction], iri]
    graph << [::RDF::DynamicURI(requested_url), NS::ARGU[:favoriteAction], iri]

    graph << [iri, RDF[:type], NS::SCHEMA[:Action]]
    graph << [iri, NS::SCHEMA[:name], label]
    graph << [iri, NS::SCHEMA[:target], entry_point_iri]
    graph << [iri, NS::SCHEMA[:object], token.iri]
    graph << [iri, NS::ARGU[:favoriteAction], true]

    graph << [entry_point_iri, RDF[:type], NS::SCHEMA[:EntryPoint]]
    graph << [entry_point_iri, NS::SCHEMA[:name], label]
    graph << [entry_point_iri, NS::ARGU[:action], NS::ONTOLA['actions/logout']]
    graph << [entry_point_iri, NS::ARGU[:href], RDF::DynamicURI(argu_url('/users/sign_out'))]
    graph << [entry_point_iri, NS::SCHEMA[:image], RDF::URI('http://fontawesome.io/icon/user-plus')]
  end

  def token
    @token ||= Token.find_by(secret: params[:token_secret])
  end
  alias requested_resource token

  def requested_url
    @requested_url ||= argu_url(request.path)
  end

  def verify_email_conflict
    redirect_to token.iri.to_s if token.email.blank? || token.email == current_user.email
  end
end
