ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'rake'

# Reading them more than once appends every task body again, so a task asked to
# run once would run as many times as the definitions had been read.
module TaskDefinitions
  def self.read_once
    return if @read

    Rails.application.load_tasks
    @read = true
  end
end

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  teardown do
    I18n.locale = I18n.default_locale
  end

  # Add more helper methods to be used by all tests here...
end
