require "test_helper"
require "yaml"

class LiveUpdatesTest < ActiveSupport::TestCase
  test "in production a live update reaches every process, not just the one that sent it" do
    assert_equal "solid_cable", live_updates_in("production").fetch("adapter")
  end

  test "development and test keep live updates in the one process running them" do
    assert_equal "async", live_updates_in("development").fetch("adapter")
    assert_equal "async", live_updates_in("test").fetch("adapter")
  end

  private

  def live_updates_in(environment)
    YAML.load_file(Rails.root.join("config/cable.yml")).fetch(environment)
  end
end
