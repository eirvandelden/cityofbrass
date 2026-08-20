require "test_helper"
require "rake"

class ImporterTestTaskTest < ActiveSupport::TestCase
  test "root test task runs importer engine tests" do
    Rails.application.load_tasks unless Rake::Task.task_defined?("test:importer")

    assert_includes Rake::Task["test"].prerequisites, "test:importer"
  end
end
