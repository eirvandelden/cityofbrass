require "test_helper"

module Gallery
  class StockImageTest < ActiveSupport::TestCase
    test "a stock picture attaches the uploaded file" do
      image = StockImage.new(name: "Stock", file: sample_picture)

      image.save!

      assert image.file.attached?
    end

    test "a stock picture has a thumb and a medium variant" do
      image = StockImage.create!(name: "Stock", file: sample_picture)

      assert_not_equal image.file_url(:thumb), image.file_url(:medium)
      assert_not_equal image.file_url(:thumb), image.file_url(:original)
    end

    test "a stock picture rejects a file larger than 2 megabytes" do
      oversized = StringIO.new("a" * 3.megabytes)
      image = StockImage.new(name: "Stock",
        file: { io: oversized, filename: "big.png", content_type: "image/png" })

      assert_not image.valid?
      assert_includes image.errors.attribute_names, :file
    end

    test "a stock picture rejects a file that is not an image" do
      document = StringIO.new("not a picture")
      image = StockImage.new(name: "Stock",
        file: { io: document, filename: "notes.txt", content_type: "text/plain" })

      assert_not image.valid?
      assert_includes image.errors.attribute_names, :file
    end

    private

    def sample_picture
      { io: File.open(Rails.root.join("test/fixtures/files/sample.png")), filename: "sample.png", content_type: "image/png" }
    end
  end
end
