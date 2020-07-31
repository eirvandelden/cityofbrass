# frozen_string_literal: false

source 'https://rubygems.org'
ruby '2.7.1'

gem 'dotenv-rails' # We want dotenv to load before everything else.

gem 'rails', '~> 5.2'
gem 'bootsnap'
# Use postgresql as the database for Active Record
gem 'pg'
# Use SCSS for stylesheets
gem 'sass-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails'
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

gem 'aws-sdk', '< 3' # 2 is out but not compatible with paperclip
gem 'delayed_paperclip', '< 4'
gem 'devise'
gem 'foundation-rails', '5.5.3.2' # git: 'https://github.com/embersds/foundation-rails', branch: 'v5'
gem 'kaminari'
gem 'omniauth'
gem 'paperclip'
gem 'puma'
gem 'redcarpet'
gem 'redis'
gem 'sidekiq'
gem 'simple_form'
gem 'stripe'
# gem 'sinatra' # used for sidekiq ui
gem 'bundle-audit'
gem 'erubis'
gem 'font-awesome-rails', '< 5'
gem 'jwt'
gem 'sentry-raven'
gem 'symbol-fstring', require: 'fstring/all' # Performance improvement
# gem 'bigdecimal' # BigDecimal support

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
