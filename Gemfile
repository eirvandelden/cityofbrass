# frozen_string_literal: false

source 'https://gem.coop'
#ruby file: ".ruby-version"

gem 'dotenv-rails' # We want dotenv to load before everything else.

gem 'rails', '~> 6.1.7'
gem 'bootsnap', '>= 1.4.4'
# Use sqlite3 as the database for Active Record
gem 'sqlite3', '~> 1.4'
# Use SCSS for stylesheets
gem 'sass-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'terser'  # Modern JS compressor for Rails 7
# Use CoffeeScript for .js.coffee assets and views
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc'

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring

# Keep old aws-sdk v2 for Paperclip - will switch to aws-sdk-s3 in Phase 2
gem 'aws-sdk', '< 3'
gem 'delayed_paperclip', '< 4'
gem 'paperclip'
# TODO Phase 2: Add aws-sdk-s3 and image_processing when migrating to ActiveStorage
gem 'devise'
gem 'foundation-rails', '5.5.3.2' # git: 'https://github.com/embersds/foundation-rails', branch: 'v5'
gem 'kaminari'
gem 'omniauth'
gem 'puma'
gem 'redcarpet'
gem 'redis'
gem 'sidekiq'
gem 'simple_form'
gem 'stripe'
# gem 'sinatra' # used for sidekiq ui
gem 'bundle-audit'
gem 'erubis'
gem 'font-awesome-rails'  # Remove version constraint for Rails 6.1
gem 'jwt'
gem 'symbol-fstring', require: 'fstring/all' # Performance improvement
# gem 'bigdecimal' # BigDecimal support

# bugs - allow json to upgrade for Rails 6.1
gem "json", ">= 2.0"
gem "psych", "~> 3.3"  # Rails 6.1 compatible

# City of Brass
gem 'activeplay', path: 'engines/activeplay'
gem 'billing', path: 'engines/billing'
gem 'campaignmanager', path: 'engines/campaignmanager'
gem 'entitybuilder', path: 'engines/entitybuilder'
gem 'gallery', path: 'engines/gallery'
gem 'report', path: 'engines/report'
gem 'rulebuilder', path: 'engines/rulebuilder'
gem 'storybuilder', path: 'engines/storybuilder'
gem 'support', path: 'engines/support'
gem 'worldbuilder', path: 'engines/worldbuilder'

group :development, :test do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'figaro'
  gem 'foreman'
  gem 'get_process_mem'
  gem 'listen', '~> 3.0.5'
  gem 'meta_request'
  gem 'rails-controller-testing'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :production, :staging do
  gem 'newrelic_rpm'
  gem 'rails_12factor'
end

# gem "sqlite_extensions-uuid", "~> 1.0"  # Removed - using UuidPrimaryKey concern instead

# Rails 6.1 requires minitest 5.14.x (not 6.x)
gem 'minitest', '~> 5.14.0'
