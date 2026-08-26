require "test_helper"

class ErrorNotificationTest < ActiveSupport::TestCase
  test "failures are reported through the app's own background work" do
    assert_equal :active_job, reporting_runs_on
  end

  private

  def reporting_runs_on
    source = Rails.root.join("config/initializers/exception_notification.rb").read
    source[/background:\s*:(\w+)/, 1].to_sym
  end
end
