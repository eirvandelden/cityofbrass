module GalleryPictureValidationsTest
  extend ActiveSupport::Concern

  included do
    test "attaches the uploaded file" do
      image = build_picture(file: sample_picture)

      image.save!

      assert image.file.attached?
    end

    test "rejects a file larger than the maximum size" do
      oversized = StringIO.new("a" * (picture_class.max_file_size + 1.megabyte))

      assert_picture_invalid(io: oversized, filename: "big.png", content_type: "image/png")
    end

    test "rejects a file that is not an image" do
      document = StringIO.new("not a picture")

      assert_picture_invalid(io: document, filename: "notes.txt", content_type: "text/plain")
    end

    test "rejects a file whose declared type does not match its real bytes" do
      spoofed = StringIO.new("a" * 100)

      assert_picture_invalid(io: spoofed, filename: "big.png", content_type: "image/png")
    end

    test "rejects when no file is attached at all" do
      image = build_picture

      assert_not image.valid?
      assert_includes image.errors.attribute_names, :file
    end
  end

  private

  def assert_picture_invalid(io:, filename:, content_type:)
    image = build_picture(file: { io: io, filename: filename, content_type: content_type })

    assert_not image.valid?
    assert_includes image.errors.attribute_names, :file
  end

  def build_picture(file: :omitted)
    attributes = picture_attributes
    attributes = attributes.merge(file: file) unless file == :omitted
    picture_class.new(attributes)
  end

  def sample_picture
    { io: File.open(Rails.root.join("test/fixtures/files/sample.png")), filename: "sample.png", content_type: "image/png" }
  end
end
