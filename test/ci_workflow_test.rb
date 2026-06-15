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
    assert_equal "redis://localhost:6379/0", test_job.dig("env", "REDIS_URL")
    assert_includes run_commands("test"), "bin/rails db:schema:load"
    assert_includes run_commands("test"), "bin/rails test"
  end

  def test_test_job_provides_redis_for_sidekiq_web
    redis = test_job.dig("services", "redis")

    assert_equal "redis:7-alpine", redis.fetch("image")
    assert_includes redis.fetch("ports"), "6379:6379"
    assert_match(/redis-cli ping/, redis.fetch("options"))
  end

  def test_test_job_installs_imagemagick_for_paperclip
    assert imagemagick_step, "Expected CI test job to install ImageMagick"
    assert_operator imagemagick_step_index, :<, database_setup_step_index
    assert_match(/apt-get install -y imagemagick/, imagemagick_step.fetch("run"))
  end

  def test_ci_sets_up_chrome_before_running_system_tests
    assert_operator setup_chrome_step_index, :<, system_test_step_index
    assert_equal "${{ steps.setup-chrome.outputs.chrome-path }}", system_test_step.dig("env", "BROWSER_PATH")
  end

  def test_ci_runs_regular_and_system_tests_separately
    assert_match(/bin\/rails test$/, regular_test_step.fetch("run"))
    assert_match(/bin\/rails test:system$/, system_test_step.fetch("run"))
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

  def regular_test_step
    steps("test").find { |step| step["name"] == "Run tests" }
  end

  def database_setup_step_index
    steps("test").index(database_setup_step)
  end

  def database_setup_step
    steps("test").find { |step| step["name"] == "Set up database" }
  end

  def imagemagick_step_index
    steps("test").index(imagemagick_step)
  end

  def imagemagick_step
    steps("test").find { |step| step["name"] == "Install ImageMagick" }
  end

  def setup_chrome_step_index
    steps("test").index(setup_chrome_step)
  end

  def setup_chrome_step
    steps("test").find { |step| step["uses"] == "browser-actions/setup-chrome@v1" }
  end

  def system_test_step
    steps("test").find { |step| step["name"] == "Run system tests" }
  end

  def system_test_step_index
    steps("test").index(system_test_step)
  end
end
