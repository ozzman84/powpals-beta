# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.4.12'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 8.1.0'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem 'sprockets-rails'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '>= 8.0.2'

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem 'importmap-rails'

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails'

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails'

# Use Tailwind CSS [https://github.com/rails/tailwindcss-rails]
gem 'tailwindcss-rails'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'devise', '>= 5.0.4'
gem 'pundit'
gem 'dotenv-rails'
gem 'httparty', '>= 0.24.0'
gem 'jbuilder', '>= 2.14.1'
gem 'omniauth'
gem 'omniauth-google-oauth2'
gem 'omniauth-rails_csrf_protection'

gem 'dalli', '~> 3.2.13'
gem 'geocoder'
gem 'rake'
gem 'csv'
gem 'json', '~> 2.19'
gem 'sidekiq', '>= 7.2.4'

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.24.4', require: false

# Use Sass to process CSS
# gem "sassc-rails"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'capybara'
  gem 'capybara-email'
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'factory_bot_rails', '>= 6.5'
  gem 'webmock'
  gem 'faker'
  gem 'launchy'
  gem 'orderly'
  gem 'pry'
  gem 'pry-rails', '~> 0.3.9'
  gem 'rspec-rails', '~> 8.0'
  gem 'shoulda-matchers'
  gem 'simplecov', require: false, group: :test
  gem 'cuprite'

  # Security
  gem 'brakeman', '>= 8.0.4', require: false
  gem 'bundler-audit', '>= 0.9.3', require: false
  gem 'ruby_audit'

  # Linting
  gem 'erb_lint', '>= 0.9', require: false
  gem 'gitlab-styles', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop', '>= 1.81.7', require: false
  gem 'rubocop-capybara', '>= 2.21', require: false
  gem 'rubocop-factory_bot', '>= 2.26.1', require: false
  gem 'rubocop-rails', '>= 2.29.1', require: false
  gem 'rubocop-rspec', '>= 3.4', require: false
end

group :development do
  gem 'foreman', require: false
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'letter_opener'
  gem 'web-console'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

gem 'dockerfile-rails', '>= 1.5', group: :development
gem 'rack-mini-profiler'
# For memory profiling
gem 'memory_profiler'

# For call-stack profiling flamegraphs
gem 'stackprof'

gem 'redis', '~> 5.0'

gem 'sentry-ruby', '>= 6.6.2'

gem 'sentry-rails', '>= 6.6.2'

# Security floors for existing indirect dependencies, refreshed by bundler-audit.
gem 'addressable', '>= 2.9.0', require: false
gem 'crass', '>= 1.0.8', require: false
gem 'faraday', '>= 2.14.3', require: false
gem 'jwt', '~> 2.10.3', require: false
gem 'loofah', '>= 2.25.2', require: false
gem 'mail', '>= 2.9.1', require: false
gem 'net-imap', '>= 0.6.4.1', require: false
gem 'nokogiri', '>= 1.19.4', require: false
gem 'oauth2', '>= 2.0.22', require: false
gem 'rack', '~> 2.2.23', require: false
gem 'rails-html-sanitizer', '>= 1.7.1', require: false
gem 'rdoc', '>= 6.5.1.1', require: false
gem 'rexml', '>= 3.3.9', require: false
