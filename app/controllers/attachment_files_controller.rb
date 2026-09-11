class AttachmentFilesController < ApplicationController
  def show
    return head :not_found unless attachment_record
    return head :forbidden unless allowed_to_show_attachment?

    variant = requested_variant
    return head :not_found unless variant

    expires_in 1.day, public: publicly_cacheable?
    send_data variant.download, type: variant.content_type, disposition: "inline"
  end

  private

  def publicly_cacheable?
    case attachment_record
    when Gallery::StockImage, Gallery::MapImage
      true
    else
      false
    end
  end

  def attachment_record
    @attachment_record ||= case path_segments
    in [ "gallery", collection_name, id, _ ]
      Gallery::Image::ATTACHMENT_SEGMENTS[collection_name]&.constantize&.find_by(id: id)
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

    variant = requested_named_variant(style)
    return unless variant

    processed_variant(variant)
  end

  def requested_named_variant(style)
    attachment_record.file.variant(style.to_sym)
  rescue ArgumentError
    nil
  end

  def processed_variant(variant)
    variant.processed
  rescue Vips::Error
    nil
  end

  def path_segments
    @path_segments ||= params[:path].to_s.split("/")
  end
end
