# frozen_string_literal: true

class ApplicationController < APIController
  include ActiveResponse::Controller
  include ActiveResponseHelper

  private

  def parent_resource_klass(opts = params)
    super || ActiveResourceModel.descendants.detect { |m| m.to_s == parent_resource_type(opts)&.classify }
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
