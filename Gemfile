source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.3"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# Use PostgreSQL as the database for Active Record
gem "pg", "~> 1.5"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem "jsbundling-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
# Bundle and process CSS [https://github.com/rails/cssbundling-rails]
gem "cssbundling-rails"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Authentication (email + password) [https://github.com/heartcombo/devise]
gem "devise"
# Multi-channel notifications: in-app (DB), email, and future mobile push [https://github.com/excid3/noticed]
gem "noticed"
# Redis: Action Cable pub/sub, Sidekiq queue, and Rails cache store
gem "redis", ">= 4.0.1"
# Sidekiq 7.3 scheduler is incompatible with connection_pool 3.x
gem "connection_pool", "~> 2.4"
# Background job processing for heavy workers (mass comment generation, re-indexing)
gem "sidekiq", "~> 7.3"
# Full-text search engine integration for comments [https://github.com/meilisearch/meilisearch-rails]
gem "meilisearch-rails"
# Tree-structured comments via materialized path [https://github.com/stefankroes/ancestry]
gem "ancestry", "~> 4.3"
# Generate realistic fake data for the bulk comment generator
gem "faker"
# Image variants for user avatars
gem "image_processing", "~> 1.2"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false

  # Readable, DRY test data [https://github.com/thoughtbot/factory_bot_rails]
  gem "factory_bot_rails"

  # N+1 query detection [https://github.com/charkost/prosopite]
  gem "prosopite"
  # Required by Prosopite for PostgreSQL query parsing
  gem "pg_query"
end

group :test do
  # Test coverage measurement / enforcement
  gem "simplecov", require: false
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
end
