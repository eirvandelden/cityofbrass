require "open3"

module PrePushChecks
  TEST_FILE_PATTERN = %r{\A(?:test|engines/[^/]+/test)/.*_test\.rb\z}

  module_function

  def changed_files(base_ref: ENV.fetch("BASE_REF", "origin/main"))
    stdout, status = Open3.capture2(
      "git", "diff", "--diff-filter=ACMR", "--name-only", "#{base_ref}...HEAD"
    )
    raise "git diff failed for #{base_ref}...HEAD" unless status.success?

    stdout.lines.map(&:chomp).reject(&:empty?)
  end

  def ruby_files(files)
    files.select { |path| path.end_with?(".rb", ".rake") }
  end

  def test_files(files)
    files.select { |path| path.match?(TEST_FILE_PATTERN) }
  end

  def commands(files)
    planned_commands = []
    changed_ruby_files = ruby_files(files)
    changed_test_files = test_files(files)

    if changed_ruby_files.any?
      planned_commands << ["bundle", "exec", "rubocop", "--force-exclusion", *changed_ruby_files]
    end

    if changed_test_files.any?
      planned_commands << ["bin/rails", "test", *changed_test_files]
    end

    planned_commands
  end

  def run!(io: $stdout)
    files = changed_files
    changed_ruby_files = ruby_files(files)
    changed_test_files = test_files(files)

    if changed_ruby_files.any?
      return false unless run_command(["bundle", "exec", "rubocop", "--force-exclusion", *changed_ruby_files], io: io)
    else
      io.puts "No changed Ruby files to lint."
    end

    if changed_test_files.any?
      return false unless run_command(["bin/rails", "test", *changed_test_files], io: io)
    else
      io.puts "No changed test files to run."
    end

    true
  end

  def run_command(command, io:)
    io.puts command.join(" ")
    system(*command)
  end
end
