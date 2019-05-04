# frozen_string_literal: true

require 'token_creator'
require 'token_executor'

class EmailConflictsController < ApplicationController
  active_response :show, :update
  before_action :verify_email_conflict

  private

  def token
    @token ||= Token.find_by(secret: params[:token_secret])
  end

  def permit_params
    {}
  end

  def requested_resource
    @requested_resource ||= EmailConflict.new(api: api, token: token)
  end

  def requested_url
    @requested_url ||= argu_url(request.path)
  end

  def update_success
    respond_with_redirect(location: token.iri)
  end

  def verify_email_conflict
    redirect_to token.iri.to_s if token.email.blank? || token.email == current_user.email
  end
end
