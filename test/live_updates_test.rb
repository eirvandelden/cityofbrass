require "test_helper"
require "yaml"

class LiveUpdatesTest < ActiveSupport::TestCase
  # The suite delivers live updates within its own process, so nothing here
  # reaches for this database. It is opened only to prove the store the running
  # app depends on can actually be built.
  class LiveUpdateStore < ActiveRecord::Base
    self.abstract_class = true
    connects_to database: { writing: :cable }
  end

  test "a live update reaches every process running the app, not just the one that sent it" do
    assert_equal "solid_cable", live_updates_in("production").fetch("adapter")
    assert_equal "solid_cable", live_updates_in("development").fetch("adapter")
  end

  test "the test suite keeps live updates in the single process running it" do
    assert_equal "async", live_updates_in("test").fetch("adapter")
  end

  test "live updates have somewhere to be stored" do
    assert_includes LiveUpdateStore.connection.tables, "solid_cable_messages"
  end

  test "live updates are kept out of the application database" do
    assert_not_equal ApplicationRecord.connection_db_config.database,
      LiveUpdateStore.connection_db_config.database
  end

  private

  def live_updates_in(environment)
    YAML.load_file(Rails.root.join("config/cable.yml"), aliases: true).fetch(environment)
  end
end
