require "test_helper"
require "bundler"

class BackgroundWorkTest < ActiveSupport::TestCase
  STARTING_AND_BUILDING_THE_APP = %w[
    bin/dev
    .github/workflows/ci.yml
    config/application.example.yml
  ].freeze

  test "running the app needs no Redis server" do
    assert_not_includes app_dependencies, "sidekiq"
  end

  test "the worker runs the app's own queue" do
    assert_equal "bin/jobs", worker_command("Procfile")
    assert_equal "bin/jobs", worker_command("Procfile.dev")
  end

  test "starting the app and building it ask for no Redis server" do
    STARTING_AND_BUILDING_THE_APP.each do |path|
      assert_no_match(/redis/i, Rails.root.join(path).read, "#{path} still asks for Redis")
    end
  end

  private

  def app_dependencies
    Bundler::Dsl.evaluate(Rails.root.join("Gemfile").to_s, nil, {}).dependencies.map(&:name)
  end

  def worker_command(procfile)
    Rails.root.join(procfile).read[/^worker:\s*(.+)$/, 1]
  end
end
