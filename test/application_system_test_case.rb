require "test_helper"
require "capybara/cuprite"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include ActiveJob::TestHelper

  driven_by :cuprite, screen_size: [ 1400, 1400 ], options: {
    js_errors: true,
    process_timeout: 15
  }

  setup do
    @previous_queue_adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :test
  end

  teardown do
    clear_enqueued_jobs
    clear_performed_jobs
    ActiveJob::Base.queue_adapter = @previous_queue_adapter
  end

  private

  def sign_in_as(account, scope:)
    visit public_send("new_#{scope}_session_path")
    fill_in "Email", with: account.email
    fill_in "Password", with: "password"
    click_button "Login"
  end
end
