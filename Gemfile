# frozen_string_literal: true
source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.0', '>= 5.0.0.1'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.18'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

gem 'service_base', git: 'git@bitbucket.org:arguweb/service_base.git'
gem 'active_model_serializers', '~> 0.10.0'
gem 'dotenv-rails', require: 'dotenv/rails-now'
gem 'bugsnag', '~> 4.2.1'
gem 'tzinfo-data'

group :development, :test do
  gem 'rubocop', '~> 0.45.0'
  gem 'byebug', platform: :mri
  gem 'rspec-rails'
  gem 'factory_girl'
  gem 'factory_girl_rails'
  gem 'webmock'
  gem 'assert_difference'
  gem 'better_errors'
  gem 'binding_of_caller'

  gem 'brakeman', '~> 3.4.0'
  gem 'bundler-audit', '~> 0.5.0'
end

group :development do
  gem 'web-console'
  gem 'listen', '~> 3.0.5'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end
