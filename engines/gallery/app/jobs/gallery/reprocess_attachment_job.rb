module Gallery
  class ReprocessAttachmentJob < ApplicationJob
    queue_as :default

    def perform(model_class_name, record_id)
      record = model_class_name.constantize.find(record_id)
      record.file.reprocess!
    end
  end
end
