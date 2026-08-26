require "test_helper"
require "rake"

class TaskDefinitionsTest < ActiveSupport::TestCase
  test "asking for the task definitions again does not make a task run twice" do
    TaskDefinitions.read_once
    TaskDefinitions.read_once

    assert_equal 1, Rake::Task["db:seed:pf2e:ancestries"].actions.size
  end
end
