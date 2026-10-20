require "test_helper"

class JavascriptPackageManagerTest < ActiveSupport::TestCase
  DATA_PATHS = %w[db/seeds/ docs/changes/ test/lib/javascript_package_manager_test.rb].freeze

  test "uses package-lock.json" do
    assert_predicate Rails.root.join("package-lock.json"), :exist?, "package-lock.json must be committed"
  end

  test "has no yarn lockfile" do
    assert_not Rails.root.join("yarn.lock").exist?, "yarn.lock must be removed"
  end

  test "has no bin/yarn" do
    assert_not Rails.root.join("bin/yarn").exist?, "bin/yarn must be removed"
  end

  test "names yarn nowhere outside data" do
    assert_empty files_naming_yarn, "tracked files still name yarn: #{files_naming_yarn.join(", ")}"
  end

  private

  def files_naming_yarn
    matches = Dir.chdir(Rails.root) { `git grep -i -l yarn`.split("\n") }
    matches.reject { |path| DATA_PATHS.any? { |data_path| path.start_with?(data_path) } }
  end
end
