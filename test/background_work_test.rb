require "test_helper"
require "bundler"

class BackgroundWorkTest < ActiveSupport::TestCase
  FILES_THAT_SAY_HOW_TO_RUN_THE_APP = %w[
    bin/dev
    .github/workflows/ci.yml
    config/application.example.yml
  ].freeze

  test "nothing in the bundle can reach a Redis server" do
    assert_not_includes bundled_gems, "redis"
    assert_not_includes bundled_gems, "redis-client"
    assert_not_includes bundled_gems, "sidekiq"
  end

  test "the worker runs the app's own queue" do
    assert_equal "bin/jobs", worker_command("Procfile")
    assert_equal "bin/jobs", worker_command("Procfile.dev")
  end

  test "no file that says how to run the app asks for a Redis server" do
    FILES_THAT_SAY_HOW_TO_RUN_THE_APP.each do |path|
      assert_no_match(/redis/i, Rails.root.join(path).read, "#{path} still asks for Redis")
    end
  end

  private

  def bundled_gems
    Bundler::LockfileParser.new(Rails.root.join("Gemfile.lock").read).specs.map(&:name)
  end

  def worker_command(procfile)
    Rails.root.join(procfile).read[/^worker:\s*(.+)$/, 1]
  end
end
