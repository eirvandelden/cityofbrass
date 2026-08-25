require "test_helper"

class QueueStorageTest < ActiveSupport::TestCase
  test "the queue is ready to hold background jobs" do
    assert SolidQueue::Job.table_exists?
  end

  test "the queue keeps its jobs out of the application database" do
    assert_not_equal ApplicationRecord.connection_db_config.database,
      SolidQueue::Job.connection_db_config.database
  end

  test "work handed off for later waits in the queue" do
    assert_difference -> { SolidQueue::Job.count }, +1 do
      Gallery::ReprocessAttachmentJob.perform_later("Gallery::Image", 1)
    end
  end

  test "the queue remembers which work is waiting and where" do
    Importer::ProcessImportJob.perform_later(1)

    waiting = SolidQueue::Job.last

    assert_equal "Importer::ProcessImportJob", waiting.class_name
    assert_equal "imports", waiting.queue_name
  end
end
