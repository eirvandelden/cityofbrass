require "test_helper"
require_relative "../../support/gallery_picture_validations_test"

module Gallery
  class FaqImageTest < ActiveSupport::TestCase
    include GalleryPictureValidationsTest

    private

    def picture_class
      FaqImage
    end

    def picture_attributes
      { name: "Help" }
    end
  end
end
