require "test_helper"
require_relative "../../support/gallery_picture_validations_test"

module Gallery
  class StockImageTest < ActiveSupport::TestCase
    include GalleryPictureValidationsTest

    test "a stock picture processes a real thumbnail variant of the original file" do
      image = StockImage.create!(name: "Stock", file: sample_picture)

      thumbnail = image.file.variant(:thumb).processed.download

      assert_not_equal image.file.download, thumbnail
    end

    test "renaming an existing stock picture does not re-download the file to re-check its content type" do
      image = StockImage.create!(name: "Stock", file: sample_picture)
      image = StockImage.find(image.id)
      streamed_download = false
      subscriber = ActiveSupport::Notifications.subscribe("service_streaming_download.active_storage") do
        streamed_download = true
      end

      begin
        image.update!(name: "Renamed stock picture")
      ensure
        ActiveSupport::Notifications.unsubscribe(subscriber)
      end

      assert_not streamed_download
    end

    test "sums the actual stored byte size of every stock picture" do
      first = StockImage.create!(name: "Stock", file: sample_picture)
      second = StockImage.create!(name: "Stock 2", file: sample_picture)

      assert_equal first.file.blob.byte_size + second.file.blob.byte_size, StockImage.total_byte_size
    end

    private

    def picture_class
      StockImage
    end

    def picture_attributes
      { name: "Stock" }
    end
  end
end
