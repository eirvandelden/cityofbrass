require "test_helper"

module Report
  class GallerySnapshotsHelperTest < ActionView::TestCase
    include Report::GallerySnapshotsHelper

    test "counts every stock picture in the gallery" do
      assert_difference -> { report_stock_image_count }, 2 do
        Gallery::StockImage.create!(name: "Stock", file: sample_picture)
        Gallery::StockImage.create!(name: "Stock 2", file: sample_picture)
      end
    end

    test "sums the stored size of every stock picture into a human readable size" do
      Gallery::StockImage.create!(name: "Stock", file: sample_picture)

      assert_equal "0.7 KB", report_stock_gallery_size

      Gallery::StockImage.create!(name: "Stock 2", file: sample_picture)

      assert_equal "1.4 KB", report_stock_gallery_size
    end

    test "counts resident pictures whose owner has the given status" do
      assert_difference -> { report_resident_image_count("active") }, 1 do
        Gallery::ResidentImage.create!(name: "Portrait", resident: residents(:razune), file: sample_picture)
      end

      assert_difference -> { report_resident_image_count("free") }, 1 do
        Gallery::ResidentImage.create!(name: "Portrait", resident: residents(:tuandn), file: sample_picture)
      end
    end

    test "excludes resident pictures whose owner is not active, even when asked for that status" do
      Gallery::ResidentImage.create!(name: "Portrait", resident: residents(:eleanor), file: sample_picture)

      assert_equal 0, report_resident_image_count("suspended")
    end

    test "sums the stored size of resident pictures whose owner has the given status" do
      Gallery::ResidentImage.create!(name: "Portrait", resident: residents(:razune), file: sample_picture)

      assert_equal "0.7 KB", report_resident_gallery_size("active")
      assert_equal "0.0 KB", report_resident_gallery_size("free")
    end

    private

    def sample_picture
      { io: File.open(Rails.root.join("test/fixtures/files/sample.png")), filename: "sample.png", content_type: "image/png" }
    end
  end
end
