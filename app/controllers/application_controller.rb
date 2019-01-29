# frozen_string_literal: true

class ApplicationController < ApiController
  include ActiveResponse::Controller
  include ActiveResponseHelper

  before_action :set_tenant_header

  private

  def handle_record_not_found_html(_e)
    return super unless action_name == 'show'
    redirect_to argu_url('/token', token: params[:secret], error: 'not_found')
  end

  def set_tenant_header
    response.headers['Tenant-IRI'] = "https://#{tree_root.iri_prefix}" if tree_root
  end

  def tree_root
    ActsAsTenant.current_tenant
  end
end
