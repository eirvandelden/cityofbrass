require "test_helper"
require "capybara/cuprite"

Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(
    app,
    window_size: [ 1400, 1400 ],
    js_errors: true,
    process_timeout: 30,
    browser_options: {
      "disable-dev-shm-usage" => nil,
      "no-sandbox" => nil
    }
  )
end

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  include ActiveJob::TestHelper

  driven_by :cuprite

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
