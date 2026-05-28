require "test_helper"
require "yaml"

class CiWorkflowTest < ActiveSupport::TestCase
  def test_ci_uses_bundler_to_install_gems
    assert_nil setup_rv_step.dig("with", "install-gems")
    assert_match(/bundle install/, bundle_install_step.fetch("run"))
    assert_equal "vendor/bundle", test_job.dig("env", "BUNDLE_PATH")
  end

  private

  def workflow
    YAML.load_file(Rails.root.join(".github/workflows/ci.yml"))
  end

  def steps
    test_job.fetch("steps")
  end

  def test_job
    workflow.dig("jobs", "test")
  end

  def setup_rv_step
    steps.find { |step| step["uses"] == "spinel-coop/setup-rv@main" }
  end

  def bundle_install_step
    steps.find { |step| step["name"] == "Install gems" }
  end
end
