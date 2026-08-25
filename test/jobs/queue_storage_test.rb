require "test_helper"

class QueueStorageTest < ActiveSupport::TestCase
  test "the queue is ready to hold background jobs" do
    assert SolidQueue::Job.table_exists?
  end

  test "the queue keeps its jobs out of the application database" do
    assert_not_equal ApplicationRecord.connection_db_config.database,
      SolidQueue::Job.connection_db_config.database
  end
end
