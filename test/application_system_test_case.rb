require "test_helper"
require "capybara/cuprite"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include ActiveJob::TestHelper

  MACOS_BROWSER_PATHS = [
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
    "/Applications/Chromium.app/Contents/MacOS/Chromium",
    "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser",
    "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge"
  ].freeze

  self.use_transactional_tests = false

  class << self
    def browser_path(paths: browser_paths)
      ENV["BROWSER_PATH"] || paths.find { |path| File.executable?(path) }
    end

    def browser_paths
      MACOS_BROWSER_PATHS
    end

    def cuprite_options
      {
        browser_path: browser_path,
        js_errors: true,
        timeout: 30,
        process_timeout: 60,
        browser_options: {
          "disable-dev-shm-usage" => nil,
          "no-sandbox" => nil
        }
      }
    end
  end

  driven_by :cuprite, screen_size: [ 1400, 1400 ], options: cuprite_options

  setup do
    swap_queue_adapter_for_system_tests
  end

  teardown do
    clear_enqueued_jobs
    clear_performed_jobs
    restore_queue_adapter
  end

  private

  def swap_queue_adapter_for_system_tests
    @previous_queue_adapter_name = ActiveJob::Base.queue_adapter_name
    ActiveJob::Base.queue_adapter = :test
  end

  def restore_queue_adapter
    ActiveJob::Base.queue_adapter = previous_queue_adapter_name
  end

  def previous_queue_adapter_name
    @previous_queue_adapter_name&.to_sym || Rails.application.config.active_job.queue_adapter
  end

  def sign_in_as(account, scope:)
    visit public_send("new_#{scope}_session_path")
    fill_in "Email", with: account.email
    fill_in "Password", with: "password"
    click_button "Login"
  end
end
