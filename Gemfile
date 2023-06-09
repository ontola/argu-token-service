# frozen_string_literal: true

source 'https://rubygems.org'
ruby '3.0.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 7'
# Use Puma as the app server
gem 'puma'

gem 'active_model_serializers'
gem 'activeresource'
gem 'active_response', git: 'https://github.com/ontola/active_response', branch: :master
gem 'acts_as_tenant', git: 'https://github.com/ArthurWD/acts_as_tenant', branch: :master
gem 'bootsnap'
gem 'bugsnag'
gem 'dotenv-rails', require: 'dotenv/rails-now'
gem 'emp_json', '1.4.0'
gem 'fast_jsonapi', git: 'https://github.com/fast-jsonapi/fast_jsonapi', ref: '2de80d48896751d30fb410e042fd21a710100423'
gem 'health_check'
gem 'json-ld'
gem 'kaminari'
gem 'linked_rails', '0.0.4.pre.g8d7195543'
gem 'nokogiri'
gem 'oauth2'
gem 'oj'
gem 'openid_connect'
gem 'pragmatic_context'
gem 'pundit'
gem 'rdf'
gem 'rdf-n3'
gem 'rdf-rdfa'
gem 'rdf-rdfxml'
gem 'rdf-serializers', git: 'https://github.com/ontola/rdf-serializers', branch: 'refactor-includes'
gem 'rdf-turtle'
gem 'rfc-822'
gem 'sidekiq'
gem 'tzinfo-data'
gem 'uri_template'

group :development, :production do
  gem 'pg'
end

group :development, :test do
  gem 'binding_of_caller'
  gem 'brakeman'
  gem 'bundler-audit'
  gem 'byebug', platform: :mri
  gem 'rspec-rails'
  gem 'rubocop', '~> 0.92.0'
  gem 'rubocop-rails', '~> 2.5.2'
  gem 'rubocop-rspec', '~> 1.39.0'
end

group :development do
  gem 'better_errors'
  gem 'listen'
  gem 'web-console'
end

group :test do
  gem 'assert_difference'
  gem 'factory_girl'
  gem 'factory_girl_rails'
  gem 'fakeredis',
      require: false,
      git: 'https://github.com/magicguitarist/fakeredis',
      branch: 'fix-sadd-return-when-0-or-1'
  gem 'minitest-reporters'
  gem 'sqlite3'
  gem 'webmock'
end
