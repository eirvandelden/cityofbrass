module Gallery
  class Image < ApplicationRecord
    include KeysToGallery

    scope :order_name, -> { order(:name) }

    has_many :image_joins, :class_name => "Gallery::ImageJoin", dependent: :destroy
  end
end
