# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'action_cable/engine'
# require "sprockets/railtie"
require 'rails/test_unit/railtie'

require_relative 'initializers/version'
require_relative 'initializers/build'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require 'linked_rails/middleware/linked_data_params'
require_relative '../lib/tenant_finder'
require_relative '../lib/tenant_middleware'
require_relative '../lib/ns'
require_relative '../lib/acts_as_tenant/sidekiq_for_service'

module Service
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true
    config.frontend_url = "https://#{ENV['FRONTEND_HOSTNAME'] || "app.#{ENV['HOSTNAME']}"}"
    config.host_name = ENV['HOSTNAME']
    config.origin = "https://#{config.host_name}"
    LinkedRails.host = config.host_name
    LinkedRails.scheme = :https

    config.middleware.use ActionDispatch::Flash
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore,
                          key: '_Argu_sesion',
                          domain: Rails.env.staging? ? nil : :all
    config.middleware.use TenantMiddleware
    config.middleware.use LinkedRails::Middleware::LinkedDataParams

    config.autoload_paths += %w[lib]
    config.autoload_paths += %W[#{config.root}/app/serializers/base]
    config.autoload_paths += %W[#{config.root}/app/models/actions]
    config.autoload_paths += %W[#{config.root}/app/responders]
    config.autoload_paths += Dir["#{config.root}/app/enhancements/**/"]
    Dir.glob("#{config.root}/app/enhancements/**{,/*/**}/*.rb").each { |file| require_dependency file }

    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]

    Rails.application.routes.default_url_options[:host] = "#{config.host_name}/tokens"
    ActiveModelSerializers.config.key_transform = :camel_lower
  end
end
