# frozen_string_literal: false

module Report
  module GallerySnapshotsHelper

    def report_stock_image_count
      return Gallery::StockImage.count
    end

    def report_stock_gallery_size
      sum_a = Gallery::StockImage.sum(:file_file_size)
      if sum_a.present?
        sum = sum_a.to_f
        return "#{(sum/1000000).round(1)} MB" if sum >= 1000000
        return "#{(sum/1000).round(1)} KB"
      end
    end

    def report_resident_image_count(status)
      return Gallery::ResidentImage.joins(:user).where("users.status in (?)", status).count
    end

    def report_resident_gallery_size(status)
      sum_a = Gallery::ResidentImage.joins(:user).where("users.status in (?)", status).sum(:file_file_size)
      if sum_a.present?
        sum = sum_a.to_f
        return "#{(sum/1000000).round(1)} MB" if sum >= 1000000
        return "#{(sum/1000).round(1)} KB"
      end
    end

  end
end
