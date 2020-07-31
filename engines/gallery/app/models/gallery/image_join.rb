# frozen_string_literal: false

module Gallery
  class ImageJoin < ApplicationRecord

    belongs_to :image
    belongs_to :imageable, :polymorphic => true

    validates :imageable_type, presence: true, allow_nil: false

  end
end
