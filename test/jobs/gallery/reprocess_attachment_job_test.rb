require "test_helper"

module Gallery
  class ReprocessAttachmentJobTest < ActiveJob::TestCase
    test "job is queued in the default queue" do
      assert_equal "default", ReprocessAttachmentJob.new.queue_name
    end

    test "job is discarded when model class name does not exist" do
      assert_nothing_raised do
        perform_enqueued_jobs do
          ReprocessAttachmentJob.perform_later("Gallery::NonExistentClass", 1)
        end
      end
    end
  end
end
