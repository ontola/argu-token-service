# frozen_string_literal: true
source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.1'
# Use Puma as the app server
gem 'puma', '~> 3.9.1'

gem 'active_model_serializers', '~> 0.10.3'
gem 'activeresource',
    git: 'https://github.com/rails/activeresource',
    ref: 'e28f907145c34bcad1d354fa9b25fbd4264e52e9'
gem 'bugsnag', '~> 5.0.1'
gem 'bunny'
gem 'dotenv-rails', require: 'dotenv/rails-now'
gem 'health_check'
gem 'oauth2'
gem 'pragmatic_context'
gem 'pundit', '~> 1.0.0'
gem 'tzinfo-data'
gem 'uri_template'

group :development, :production do
  gem 'pg', '~> 0.19.0'
end

group :development, :test do
  gem 'binding_of_caller'
  gem 'brakeman', '~> 3.4.1'
  gem 'bundler-audit', '~> 0.5.0'
  gem 'byebug', platform: :mri
  gem 'rspec-rails'
  gem 'rubocop', '~> 0.46.0'
end

group :development do
  gem 'better_errors'
  gem 'listen', '~> 3.1.5'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.1'
  gem 'web-console'
end

group :test do
  gem 'assert_difference'
  gem 'factory_girl'
  gem 'factory_girl_rails'
  gem 'sqlite3', '~> 1.3.13'
  gem 'webmock'
end
