require "test_helper"
require "application_system_test_case"

class ApplicationSystemTestCaseTest < ActiveSupport::TestCase
  test "registers cuprite with CI-safe browser startup options" do
    driver = Capybara.drivers[:cuprite].call(->(_env) { [ 200, {}, [] ] })

    assert driver.options[:js_errors]
    assert_equal 30, driver.options[:process_timeout]
    assert_equal [ 1400, 1400 ], driver.options[:window_size]
    assert_includes driver.options[:browser_options], "no-sandbox"
    assert_includes driver.options[:browser_options], "disable-dev-shm-usage"
  end
end
