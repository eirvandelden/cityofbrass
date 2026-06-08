module Gallery
  class Image < ApplicationRecord
    include KeysToGallery

    scope :order_name, -> { order(:name) }

    has_many :image_joins, :class_name => "Gallery::ImageJoin", dependent: :destroy

    after_commit :enqueue_file_reprocess, on: [ :create, :update ], if: :saved_change_to_file_file_name?

    def file_size
      size = file_file_size.to_f
      return "#{(size/1000000).round(1)} MB" if size >= 1000000
      return "#{(size/1000).round(1)} KB"
    end

    private

    def enqueue_file_reprocess
      Gallery::ReprocessAttachmentJob.perform_later(self.class.name, id)
    end
  end
end
