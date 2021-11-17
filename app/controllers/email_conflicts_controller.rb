# frozen_string_literal: true

require 'token_creator'
require 'token_executor'

class EmailConflictsController < ApplicationController
  active_response :show, :update
  has_singular_update_action
  before_action :verify_email_conflict

  private

  def permit_params
    {}
  end

  def update_success
    respond_with_redirect(location: current_resource.token.iri.to_s)
  end

  def verify_email_conflict
    return unless current_resource.token.email.blank? || current_resource.token.email == current_user.email

    redirect_to current_resource.token.iri.to_s
  end
end
