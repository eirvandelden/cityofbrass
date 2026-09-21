module Report
  module GallerySnapshotsHelper

    def report_stock_image_count
      return Gallery::StockImage.count
    end

    def report_stock_gallery_size
      Gallery::Image.format_byte_size(Gallery::StockImage.total_byte_size)
    end

    def report_resident_image_count(status)
      return Gallery::ResidentImage.joins(:user).where("users.status in (?)", status).count
    end

    def report_resident_gallery_size(status)
      Gallery::Image.format_byte_size(Gallery::ResidentImage.joins(:user).where("users.status in (?)",
status).total_byte_size)
    end

  end
end
