require "test_helper"
require "yaml"

class DeploymentTest < ActiveSupport::TestCase
  test "no Redis server is deployed alongside the app" do
    assert_empty deployment.fetch("accessories", {})
    assert_not_includes settings_given_to_the_app, "REDIS_URL"
  end

  test "background jobs run inside the web server" do
    assert_equal [ "web" ], deployment.fetch("servers").keys
    assert deployment.dig("env", "clear", "SOLID_QUEUE_IN_PUMA")
  end

  test "the web server actually starts the queue when deployment asks it to" do
    assert_includes web_server_plugins_when_asked_to_run_jobs, "solid_queue"
  end

  test "the database has a connection spare for every web thread" do
    assert_operator connections_available, :>=, web_threads
  end

  test "the queue database is kept between releases" do
    kept_between_releases = deployment.fetch("volumes").any? { |volume| volume.end_with?("/rails/storage") }

    assert kept_between_releases
    assert_match %r{\Astorage/db/}, queue_database_path
  end

  private

  def web_server_plugins_when_asked_to_run_jobs
    require "puma/configuration"
    asked_before = ENV["SOLID_QUEUE_IN_PUMA"]
    ENV["SOLID_QUEUE_IN_PUMA"] = "1"
    Puma::Configuration.new { |puma| puma.load Rails.root.join("config/puma.rb").to_s }.clamp
    Puma::Plugins.instance_variable_get(:@plugins).keys
  ensure
    ENV["SOLID_QUEUE_IN_PUMA"] = asked_before
  end

  def web_threads
    default_from(Rails.root.join("config/puma.rb"))
  end

  def connections_available
    default_from(Rails.root.join("config/database.yml"))
  end

  def default_from(path)
    path.read[/MAX_THREADS", (\d+)/, 1].to_i
  end

  def deployment
    YAML.load_file(Rails.root.join("config/deploy.yml"))
  end

  def settings_given_to_the_app
    deployment.dig("env", "clear").keys
  end

  def queue_database_path
    ActiveRecord::Base.configurations
      .configs_for(env_name: "production", name: "queue")
      .database
  end
end
