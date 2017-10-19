web: bundle exec puma -C config/puma.rb
worker: bundle exec sidekiq -c 8 -q default -q mailers -q paperclip
