module Gallery
  class ReprocessAttachmentJob < ApplicationJob
    queue_as :default
    discard_on ActiveRecord::RecordNotFound
    discard_on NameError

    def perform(model_class_name, record_id)
      record = model_class_name.constantize.find(record_id)
      record.file.reprocess!
    end
  end
end
