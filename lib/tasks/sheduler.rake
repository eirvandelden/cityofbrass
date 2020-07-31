# frozen_string_literal: false

desc "This task is called by the Heroku scheduler add-on"
task :trial_warning => :environment do
  puts "Check for trials ending in 3 days..."
  User.trial_expiration_warning
  puts "done."
end

task :cancel_trials => :environment do
  puts "Check for expired trials..."
  User.cancel_trials
  puts "done."
end
