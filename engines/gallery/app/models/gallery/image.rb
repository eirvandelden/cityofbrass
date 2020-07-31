# frozen_string_literal: false

module Gallery
  class Image < ApplicationRecord
    include KeysToGallery

    scope :order_name, -> { order(:name) }

    has_many :image_joins, :class_name => "Gallery::ImageJoin", dependent: :destroy

    def file_size
      size = file_file_size.to_f
      return "#{(size/1000000).round(1)} MB" if size >= 1000000
      return "#{(size/1000).round(1)} KB"
    end

  end
end
