require "test_helper"
require_relative "../../support/gallery_picture_validations_test"

module Gallery
  class MapImageTest < ActiveSupport::TestCase
    include GalleryPictureValidationsTest

    test "a map picture processes a real thumbnail variant of the original file" do
      image = MapImage.create!(name: "Map", file: sample_picture)

      thumbnail = image.file.variant(:thumb).processed.download

      assert_not_equal image.file.download, thumbnail
    end

    private

    def picture_class
      MapImage
    end

    def picture_attributes
      { name: "Map" }
    end
  end
end
