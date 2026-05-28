require "test_helper"
require "yaml"

class CiWorkflowTest < ActiveSupport::TestCase
  def test_ci_uses_rv_to_install_gems
    assert_nil setup_rv_step.dig("with", "install-gems")
    assert_match(/rv clean-install --force/, gem_install_step.fetch("run"))
    assert_equal "vendor/bundle", test_job.dig("env", "BUNDLE_PATH")
    assert_nil test_job.dig("env", "BUNDLE_FORCE_RUBY_PLATFORM")
  end

  def test_ci_disables_spring_for_binstub_commands
    assert_equal "1", test_job.dig("env", "DISABLE_SPRING")
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

  def gem_install_step
    steps.find { |step| step["name"] == "Install gems" }
  end
end
