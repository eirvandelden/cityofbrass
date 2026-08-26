require "test_helper"
require "yaml"
require "puma/configuration"

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
    web_server_asked_to_run_jobs

    assert_includes started_plugin_names, "solid_queue"
  end

  test "the database has a connection spare for every web thread" do
    assert_operator connections_the_database_offers, :>=, threads_the_web_server_runs
  end

  test "the queue database is kept between releases" do
    kept_between_releases = deployment.fetch("volumes").any? { |volume| volume.end_with?("/rails/storage") }

    assert kept_between_releases
    assert_match %r{\Astorage/db/}, queue_database_path
  end

  private

  # Puma publishes no list of the plugins it started, and the names are the only
  # way to tell a queue that actually starts from a config file that mentions one.
  def started_plugin_names
    Puma::Plugins.instance_variable_get(:@plugins).keys
  end

  def threads_the_web_server_runs
    web_server_asked_to_run_jobs.final_options[:max_threads]
  end

  def web_server_asked_to_run_jobs
    asked_before = ENV["SOLID_QUEUE_IN_PUMA"]
    ENV["SOLID_QUEUE_IN_PUMA"] = "1"
    Puma::Configuration.new { |puma| puma.load Rails.root.join("config/puma.rb").to_s }.tap(&:clamp)
  ensure
    ENV["SOLID_QUEUE_IN_PUMA"] = asked_before
  end

  def connections_the_database_offers
    ActiveRecord::Base.configurations
      .configs_for(env_name: "production", name: "primary")
      .max_connections
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
