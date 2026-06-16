require "test_helper"
require "yaml"

class LefthookConfigTest < ActiveSupport::TestCase
  def test_pre_commit_lints_staged_ruby_files
    rubocop_command = config.dig("pre-commit", "commands", "rubocop")

    assert_equal "*.{rb,rake}", rubocop_command.fetch("glob")
    assert_match(/bundle exec rubocop --force-exclusion \{staged_files\}/, rubocop_command.fetch("run"))
  end

  def test_pre_push_runs_changed_file_checks
    commands = config.dig("pre-push", "commands")
    runs = commands.values.map { |command| command.fetch("run") }

    assert_includes runs, "rv run bin/pre_push_checks"
  end

  private

  def config
    YAML.load_file(Rails.root.join("lefthook.yml"))
  end
end
