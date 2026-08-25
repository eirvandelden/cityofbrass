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

  test "the queue database is kept between releases" do
    kept_between_releases = deployment.fetch("volumes").any? { |volume| volume.end_with?("/rails/storage") }

    assert kept_between_releases
    assert_match %r{\Astorage/db/}, queue_database_path
  end

  private

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
