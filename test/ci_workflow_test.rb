require "test_helper"
require "yaml"

class CiWorkflowTest < ActiveSupport::TestCase
  def test_ci_has_separate_lint_and_test_jobs
    assert_includes workflow.fetch("jobs").keys, "lint_ruby"
    assert_includes workflow.fetch("jobs").keys, "test"
  end

  def test_lint_job_uses_setup_rv_and_runs_rubocop
    assert_equal true, setup_rv_step("lint_ruby").dig("with", "install-gems")
    assert_equal "current", setup_rv_step("lint_ruby").dig("with", "ruby-version")
    assert_match(/bundle exec rubocop --parallel --format github/, run_commands("lint_ruby").join("\n"))
  end

  def test_test_job_uses_setup_rv_and_runs_full_tests
    assert_equal true, setup_rv_step("test").dig("with", "install-gems")
    assert_equal "current", setup_rv_step("test").dig("with", "ruby-version")
    assert_equal "1", test_job.dig("env", "DISABLE_SPRING")
    assert_includes run_commands("test"), "bin/rails db:schema:load"
    assert_includes run_commands("test"), "bin/rails test"
  end

  private

  def workflow
    YAML.load_file(Rails.root.join(".github/workflows/ci.yml"))
  end

  def steps(job_name)
    workflow.dig("jobs", job_name).fetch("steps")
  end

  def test_job
    workflow.dig("jobs", "test")
  end

  def setup_rv_step(job_name)
    steps(job_name).find { |step| step["uses"] == "spinel-coop/setup-rv@main" }
  end

  def run_commands(job_name)
    steps(job_name).filter_map { |step| step["run"] }
  end
end
