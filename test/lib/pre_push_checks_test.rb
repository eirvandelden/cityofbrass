require "test_helper"
require "stringio"
require Rails.root.join("lib/pre_push_checks")

class PrePushChecksTest < ActiveSupport::TestCase
  test ".ruby_files selects Ruby and Rake files" do
    files = [
      "app/models/user.rb",
      "lib/tasks/pf2e.rake",
      "test/models/user_test.rb",
      "README.md"
    ]

    assert_equal files.first(3), PrePushChecks.ruby_files(files)
  end

  test ".test_files selects top-level and engine test files" do
    files = [
      "app/models/user.rb",
      "test/models/user_test.rb",
      "engines/entitybuilder/test/models/stock_creature_test.rb",
      "test/fixtures/users.yml"
    ]

    assert_equal files.slice(1, 2), PrePushChecks.test_files(files)
  end

  test ".commands includes rubocop and rails test commands for changed files" do
    files = [
      "app/models/user.rb",
      "lib/tasks/pf2e.rake",
      "test/models/user_test.rb",
      "engines/entitybuilder/test/models/stock_creature_test.rb"
    ]

    assert_equal [
      ["bundle", "exec", "rubocop", "--force-exclusion", *files],
      ["bin/rails", "test", *files.slice(2, 2)]
    ], PrePushChecks.commands(files)
  end

  test ".run! reports skipped checks when no changed Ruby or test files exist" do
    output = StringIO.new

    with_replaced_method(
      PrePushChecks,
      :changed_files,
      replacement: -> { ["README.md"] }
    ) do
      assert PrePushChecks.run!(io: output)
    end

    assert_match(/No changed Ruby files to lint\./, output.string)
    assert_match(/No changed test files to run\./, output.string)
  end

  test ".run! stops when a command fails" do
    output = StringIO.new
    executed_commands = []

    with_replaced_method(
      PrePushChecks,
      :changed_files,
      replacement: -> { ["app/models/user.rb", "test/models/user_test.rb"] }
    ) do
      with_replaced_method(PrePushChecks, :run_command, replacement: lambda { |command, io:|
        executed_commands << command
        false
      }) do
        assert_not PrePushChecks.run!(io: output)
      end
    end

    assert_equal [["bundle", "exec", "rubocop", "--force-exclusion", "app/models/user.rb", "test/models/user_test.rb"]], executed_commands
  end

  private

  def with_replaced_method(object, method_name, replacement:)
    original_method = object.method(method_name)
    object.define_singleton_method(method_name, &replacement)
    yield
  ensure
    object.define_singleton_method(method_name, &original_method)
  end
end
