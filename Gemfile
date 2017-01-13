# frozen_string_literal: true
source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.0.1'
# Use Puma as the app server
gem 'puma', '~> 3.6.2'

gem 'active_model_serializers', '~> 0.10.3'
gem 'bugsnag', '~> 5.0.1'
gem 'dotenv-rails', require: 'dotenv/rails-now'
gem 'service_base', git: 'git@bitbucket.org:arguweb/service_base.git'
gem 'tzinfo-data'

group :development, :production do
  # Use postgresql as the database for Active Record
  gem 'pg', '~> 0.19.0'
end

group :development, :test do
  gem 'assert_difference'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'brakeman', '~> 3.4.1'
  gem 'bundler-audit', '~> 0.5.0'
  gem 'byebug', platform: :mri
  gem 'factory_girl'
  gem 'factory_girl_rails'
  gem 'rspec-rails'
  gem 'rubocop', '~> 0.46.0'
  gem 'webmock'
end

group :development do
  gem 'listen', '~> 3.1.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.1'
  gem 'web-console'
end

group :test do
  gem 'sqlite3', '~> 1.3.13'
end
