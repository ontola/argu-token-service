# frozen_string_literal: true

source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails'
# Use Puma as the app server
gem 'puma'

gem 'active_model_serializers'
gem 'active_response', git: 'https://github.com/ontola/active_response', branch: :master
gem 'activeresource', git: 'https://github.com/ArthurWD/activeresource', branch: :master
gem 'acts_as_tenant', git: 'https://github.com/ArthurWD/acts_as_tenant', branch: :master
gem 'bootsnap'
gem 'bugsnag'
gem 'bunny'
gem 'dotenv-rails', require: 'dotenv/rails-now'
gem 'fast_jsonapi', git: 'https://github.com/fast-jsonapi/fast_jsonapi', ref: '2de80d48896751d30fb410e042fd21a710100423'
gem 'health_check'
gem 'json-ld'
gem 'kaminari'
gem 'linked_rails', git: 'https://github.com/ontola/linked_rails', branch: 'filtering'
gem 'nokogiri'
gem 'oauth2'
gem 'oj'
gem 'pragmatic_context'
gem 'pundit'
gem 'rdf'
gem 'rdf-n3'
gem 'rdf-rdfa'
gem 'rdf-rdfxml'
gem 'rdf-serializers', git: 'https://github.com/ontola/rdf-serializers', branch: 'fast-jsonapi'
gem 'rdf-turtle'
gem 'rfc-822'
gem 'ros-apartment', git: 'https://github.com/ArthurWD/apartment', ref: '4eb1681', require: 'apartment'
gem 'sidekiq', github: 'mperham/sidekiq', branch: '5-x'
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
  gem 'rubocop'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'
end

group :development do
  gem 'better_errors'
  gem 'listen'
  gem 'spring'
  gem 'spring-watcher-listen'
  gem 'web-console'
end

group :test do
  gem 'assert_difference'
  gem 'factory_girl'
  gem 'factory_girl_rails'
  gem 'minitest-reporters'
  gem 'sqlite3'
  gem 'webmock'
end
