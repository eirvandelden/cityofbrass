require "test_helper"
require_relative "../../support/gallery_picture_validations_test"

module Gallery
  class ResidentImageTest < ActiveSupport::TestCase
    include GalleryPictureValidationsTest

    test "a resident picture processes a real thumbnail variant of the original file" do
      image = ResidentImage.create!(name: "Portrait", resident: residents(:razune), file: sample_picture)

      thumbnail = image.file.variant(:thumb).processed.download

      assert_not_equal image.file.download, thumbnail
    end

    private

    def picture_class
      ResidentImage
    end

    def picture_attributes
      { name: "Portrait", resident: residents(:razune) }
    end
  end
end
