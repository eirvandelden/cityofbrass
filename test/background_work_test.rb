require "test_helper"
require "bundler"

class BackgroundWorkTest < ActiveSupport::TestCase
  test "running the app needs no Redis server" do
    assert_not_includes app_dependencies, "sidekiq"
  end

  test "the worker runs the app's own queue" do
    assert_equal "bin/jobs", worker_command("Procfile")
    assert_equal "bin/jobs", worker_command("Procfile.dev")
  end

  private

  def app_dependencies
    Bundler::Dsl.evaluate(Rails.root.join("Gemfile").to_s, nil, {}).dependencies.map(&:name)
  end

  def worker_command(procfile)
    Rails.root.join(procfile).read[/^worker:\s*(.+)$/, 1]
  end
end
