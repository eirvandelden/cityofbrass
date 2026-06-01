require "test_helper"
require "application_system_test_case"
require "tmpdir"

class ApplicationSystemTestCaseTest < ActiveSupport::TestCase
  test "registers cuprite with CI-safe browser startup options" do
    driver = Capybara.drivers[:cuprite].call(->(_env) { [ 200, {}, [] ] })

    assert driver.options[:js_errors]
    assert_equal 30, driver.options[:process_timeout]
    assert_equal [ 1400, 1400 ], driver.options[:window_size]
    assert_includes driver.options[:browser_options], "no-sandbox"
    assert_includes driver.options[:browser_options], "disable-dev-shm-usage"
  end

  test "disables transactional tests for browser-driven system tests" do
    assert_equal false, ApplicationSystemTestCase.use_transactional_tests
  end

  test "restores the configured queue adapter after each system test" do
    test_case = ApplicationSystemTestCase.allocate
    original_adapter = ActiveJob::Base.queue_adapter

    test_case.send(:swap_queue_adapter_for_system_tests)
    assert_equal "test", ActiveJob::Base.queue_adapter_name

    test_case.send(:restore_queue_adapter)
    assert_equal original_adapter.class, ActiveJob::Base.queue_adapter.class
  end

  test "prefers the configured browser path" do
    with_env("BROWSER_PATH" => "/tmp/browser") do
      assert_equal "/tmp/browser", ApplicationSystemTestCase.browser_path
    end
  end

  test "falls back to a known macOS browser bundle" do
    Dir.mktmpdir do |dir|
      edge_path = File.join(dir, "Microsoft Edge")
      File.write(edge_path, "#!/bin/sh\n")
      File.chmod(0o755, edge_path)

      with_env("BROWSER_PATH" => nil) do
        assert_equal edge_path, ApplicationSystemTestCase.browser_path(paths: [ edge_path ])
      end
    end
  end

  private

  def with_env(overrides)
    original = overrides.keys.index_with { |key| ENV[key] }

    overrides.each do |key, value|
      value.nil? ? ENV.delete(key) : ENV[key] = value
    end

    yield
  ensure
    overrides.each_key do |key|
      previous = original[key]
      previous.nil? ? ENV.delete(key) : ENV[key] = previous
    end
  end
end
