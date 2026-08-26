require "test_helper"
require "yaml"

class LiveUpdatesTest < ActiveSupport::TestCase
  test "a live update reaches every process running the app, not just the one that sent it" do
    assert_equal "solid_cable", live_updates_in("production").fetch("adapter")
    assert_equal "solid_cable", live_updates_in("development").fetch("adapter")
  end

  test "the test suite keeps live updates in the single process running it" do
    assert_equal "async", live_updates_in("test").fetch("adapter")
  end

  private

  def live_updates_in(environment)
    YAML.load_file(Rails.root.join("config/cable.yml"), aliases: true).fetch(environment)
  end
end
