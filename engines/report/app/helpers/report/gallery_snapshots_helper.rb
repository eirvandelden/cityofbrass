module Report
  module GallerySnapshotsHelper

    def report_stock_image_count
      return Gallery::StockImage.count
    end

    def report_stock_gallery_size
      sum = Gallery::StockImage.total_byte_size.to_f
      return "#{(sum/1000000).round(1)} MB" if sum >= 1000000
      "#{(sum/1000).round(1)} KB"
    end

    def report_resident_image_count(status)
      return Gallery::ResidentImage.joins(:user).where("users.status in (?)", status).count
    end

    def report_resident_gallery_size(status)
      sum = Gallery::ResidentImage.joins(:user).where("users.status in (?)", status).total_byte_size.to_f
      return "#{(sum/1000000).round(1)} MB" if sum >= 1000000
      "#{(sum/1000).round(1)} KB"
    end

  end
end
