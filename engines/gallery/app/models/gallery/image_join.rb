module Gallery
  class ImageJoin < ApplicationRecord

    belongs_to :image, optional: true
    belongs_to :imageable, :polymorphic => true, inverse_of: :gallery_image_join

    validates :imageable_type, presence: true, allow_nil: false

  end
end
