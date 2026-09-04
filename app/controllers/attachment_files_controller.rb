class AttachmentFilesController < ApplicationController
  def show
    return head :not_found unless attachment_record
    return head :forbidden unless allowed_to_show_attachment?

    variant = requested_variant
    return head :not_found unless variant

    send_data variant.download, type: variant.content_type, disposition: "inline"
  end

  private

  def attachment_record
    @attachment_record ||= case path_segments
    in [ "gallery", "faq_images", id, _ ]
      Gallery::FaqImage.find_by(id: id)
    in [ "gallery", "stock_images", id, _ ]
      Gallery::StockImage.find_by(id: id)
    in [ "gallery", "map_images", id, _ ]
      Gallery::MapImage.find_by(id: id)
    in [ "gallery", "resident_images", id, _ ]
      Gallery::ResidentImage.find_by(id: id)
    else
      nil
    end
  end

  def allowed_to_show_attachment?
    case attachment_record
    when Gallery::FaqImage
      admin_signed_in?
    when Gallery::StockImage, Gallery::MapImage
      true
    when Gallery::ResidentImage
      admin_signed_in? || attachment_record.resident.user_id == current_user&.id
    else
      false
    end
  end

  def requested_variant
    return unless attachment_record.file.attached?

    style = path_segments.last
    return attachment_record.file if style == "original"

    attachment_record.file.variant(style.to_sym).processed
  rescue ArgumentError
    nil
  end

  def path_segments
    @path_segments ||= params[:path].to_s.split("/")
  end
end
