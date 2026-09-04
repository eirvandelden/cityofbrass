require "test_helper"

module Gallery
  class ResidentImageTest < ActiveSupport::TestCase
    test "a resident picture attaches the uploaded file" do
      image = ResidentImage.new(name: "Portrait", resident: residents(:razune), file: sample_picture)

      image.save!

      assert image.file.attached?
    end

    test "a resident picture has a thumb and a medium variant" do
      image = ResidentImage.create!(name: "Portrait", resident: residents(:razune), file: sample_picture)

      assert_not_equal image.file_url(:thumb), image.file_url(:medium)
      assert_not_equal image.file_url(:thumb), image.file_url(:original)
    end

    test "a resident picture rejects a file larger than 1 megabyte" do
      oversized = StringIO.new("a" * 2.megabytes)
      image = ResidentImage.new(name: "Portrait", resident: residents(:razune),
        file: { io: oversized, filename: "big.png", content_type: "image/png" })

      assert_not image.valid?
      assert_includes image.errors.attribute_names, :file
    end

    test "a resident picture rejects a file that is not an image" do
      document = StringIO.new("not a picture")
      image = ResidentImage.new(name: "Portrait", resident: residents(:razune),
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
