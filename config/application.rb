require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Brasscore
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.


    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.i18n.enforce_available_locales = false

    #config.action_dispatch.default_headers = {
    #  'Access-Control-Allow-Origin' => '*',
    #  'Access-Control-Request-Method' => '*'
    #}

    # set this so you we can see GC stats in New Relic
    GC::Profiler.enable
    config.active_job.queue_adapter = :sidekiq

    config.action_view.sanitized_allowed_attributes = ['name', 'href', 'cite', 'class', 'title', 'src', 'height', 'width', 'style']

    Raven.configure do |config|
      config.dsn = 'https://0c7e19e5782947038b553e385fd9a8cf:e2643685f5f84dcbadc927bf833be1eb@sentry.io/1494091'
    end
  end
end
