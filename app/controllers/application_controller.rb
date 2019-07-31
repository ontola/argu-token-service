# frozen_string_literal: true

class ApplicationController < ApiController
  include ActiveResponse::Controller
  include ActiveResponseHelper

  prepend_before_action :set_tenant_header

  private

  def handle_record_not_found_html(_e)
    return super unless action_name == 'show'
    redirect_to argu_url("/#{tree_root.url}/token", token: params[:secret], error: 'not_found')
  end

  def parent_resource_klass(opts = params)
    super || ActiveResourceModel.descendants.detect { |m| m.to_s == parent_resource_type(opts)&.classify }
  end

  def set_tenant_header
    response.headers['Website-Meta'] = website_meta.to_query if tree_root
  end

  def tree_root
    ActsAsTenant.current_tenant
  end

  def website_meta
    {
      accent_background_color: tree_root.accent_background_color,
      accent_color: tree_root.accent_color,
      iri: "https://#{tree_root.iri_prefix}",
      navbar_background: tree_root.navbar_background,
      navbar_color: tree_root.navbar_color
    }
  end
end
