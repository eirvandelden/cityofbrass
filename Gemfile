source "https://gem.coop"

ruby file: ".ruby-version"

gem "dotenv-rails" # We want dotenv to load before everything else.

gem "rails", "~> 7.1"
gem "bootsnap", ">= 1.4.4"
# Use sqlite3 as the database for Active Record
gem "sqlite3", "~> 1", force_ruby_platform: true
# Use SCSS for stylesheets
gem "sass-rails"
# Use Uglifier as compressor for JavaScript assets
gem "terser"  # Modern JS compressor for Rails 7
# Use CoffeeScript for .js.coffee assets and views
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem "jquery-rails"
# Turbo makes following links and form submissions faster.
gem "turbo-rails"
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem "jbuilder"
# bundle exec rake doc:rails generates the API under doc/api.
gem "sdoc"

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring

gem "kt-paperclip"
gem "image_processing", "~> 1.2"
gem "devise"
gem "foundation-rails", "5.5.3.2" # git: 'https://github.com/embersds/foundation-rails', branch: 'v5'
gem "kaminari"
gem "omniauth"
gem "puma"
gem "redcarpet"
gem "redis"
gem "sidekiq"
gem "connection_pool", "~> 2.5"
gem "rails-i18n"
gem "devise-i18n"
gem "stripe"
# gem 'sinatra' # used for sidekiq ui
gem "bundle-audit"
gem "font-awesome-rails"  # Remove version constraint for Rails 6.1
gem "jwt"
gem "symbol-fstring", require: "fstring/all" # Performance improvement
# gem 'bigdecimal' # BigDecimal support

# bugs - allow json to upgrade for Rails 6.1
gem "json", ">= 2.0"
gem "mutex_m" # Moved from Ruby stdlib to bundled gem in Ruby 3.3+
gem "base64"      # bundled gem in Ruby 3.4+, required before Rails boots
gem "bigdecimal"  # bundled gem in Ruby 3.4+
gem "logger"      # bundled gem in Ruby 3.4+, fixes Rails 6.1 boot order
gem "ostruct"     # bundled gem in Ruby 3.4+, silences ActiveSupport JSON warning
gem "drb"         # bundled gem in Ruby 3.4+, required by ActiveSupport test parallelization

# Gems that are no longer part of default Ruby as of Ruby 4.0
gem "benchmark"
gem "reline"

# City of Brass
gem "activeplay", path: "engines/activeplay"
gem "billing", path: "engines/billing"
gem "campaignmanager", path: "engines/campaignmanager"
gem "entitybuilder", path: "engines/entitybuilder"
gem "gallery", path: "engines/gallery"
gem "importer", path: "engines/importer"
gem "report", path: "engines/report"
gem "rulebuilder", path: "engines/rulebuilder"
gem "storybuilder", path: "engines/storybuilder"
gem "support", path: "engines/support"
gem "worldbuilder", path: "engines/worldbuilder"

group :development do
  gem "i18n-tasks"
end

group :development, :test do
  gem "better_errors"
  gem "binding_of_caller"
  gem "brakeman"
  gem "figaro"
  gem "foreman"
  gem "get_process_mem"
  gem "listen", "~> 3"
  gem "meta_request"
  gem "rails-controller-testing"
  gem "spring"
  gem "spring-watcher-listen"
  gem "rubocop"
  gem "rubocop-minitest"
  gem "rubocop-performance"
  gem "rubocop-rails"
  gem "rubocop-rails-omakase"
end

group :test do
  gem "capybara"
  gem "cuprite"
end

# gem "sqlite_extensions-uuid", "~> 1.0"  # Removed - using UuidPrimaryKey concern instead

gem "minitest", "~> 5"

gem "ed25519", "~> 1.4"
