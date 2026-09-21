module Gallery
  class Image < ApplicationRecord
    include KeysToGallery
    include HasAttachedPicture

    ATTACHMENT_SEGMENTS = {
      "faq_images"      => "Gallery::FaqImage",
      "stock_images"    => "Gallery::StockImage",
      "map_images"      => "Gallery::MapImage",
      "resident_images" => "Gallery::ResidentImage"
    }.freeze

    scope :order_name, -> { order(:name) }

    has_many :image_joins, :class_name => "Gallery::ImageJoin", dependent: :destroy

    def self.format_byte_size(bytes)
      size = bytes.to_f
      return "#{(size / 1_000_000).round(1)} MB" if size >= 1_000_000
      "#{(size / 1_000).round(1)} KB"
    end
  end
end
