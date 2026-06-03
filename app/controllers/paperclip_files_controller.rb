class PaperclipFilesController < ApplicationController
  def show
    file = storage_path.join(params[:path]).cleanpath
    return head :not_found unless file.to_s.start_with?("#{storage_path}/")
    return head :not_found unless file.file?
    return head :not_found unless attachment_record
    return head :not_found unless requested_attachment_path?(file)
    return head :forbidden unless allowed_to_show_attachment?

    send_file file, disposition: "inline"
  end

  private

  def storage_path
    Rails.root.join("storage", "paperclip")
  end

  def attachment_record
    @attachment_record ||= gallery_attachment_record || importer_attachment_record
  end

  def allowed_to_show_attachment?
    return allowed_to_show_importer_attachment? if importer_attachment?

    allowed_to_show_gallery_attachment?
  end

  def gallery_attachment_record
    case path_segments
    in [ "gallery", "residents", _, _, _, _, "images", id, _ ]
      Gallery::ResidentImage.find_by(id: id)
    in [ "gallery", "stock-images", id, _ ]
      Gallery::Image.where(type: %w[Gallery::StockImage Gallery::ProprietaryImage]).find_by(id: id)
    in [ "gallery", "map-images", id, _ ]
      Gallery::MapImage.find_by(id: id)
    in [ "gallery", "faq-images", id, _ ]
      Gallery::FaqImage.find_by(id: id)
    else
      nil
    end
  end

  def allowed_to_show_gallery_attachment?
    case attachment_record
    when Gallery::StockImage, Gallery::MapImage
      true
    when Gallery::ProprietaryImage, Gallery::FaqImage
      admin_signed_in?
    when Gallery::ResidentImage
      admin_signed_in? || attachment_record.resident.user_id == current_user&.id
    else
      false
    end
  end

  def requested_attachment_path?(file)
    attachment_paths.include?(file.to_s)
  end

  def attachment_paths
    attachment_styles.filter_map { |style| clean_attachment_path(style) }
  end

  def attachment_styles
    attachment_record.file.styles.keys + [ :original ]
  end

  def clean_attachment_path(style)
    Pathname.new(attachment_record.file.path(style)).cleanpath.to_s
  end

  def importer_attachment_record
    case path_segments
    in [ "importer", "previews", id, _ ]
      Importer::PreviewFile.find_by(id: id)
    in [ "importer", "imports", id, _ ]
      Importer::ImportFile.find_by(id: id)
    else
      nil
    end
  end

  def allowed_to_show_importer_attachment?
    return true if admin_signed_in?
    return false if importer_owner.blank?

    importer_owner.user_id == current_user&.id
  end

  def importer_owner
    return attachment_record.preview&.resident if attachment_record.is_a?(Importer::PreviewFile)

    attachment_record.import&.resident
  end

  def importer_attachment?
    attachment_record.is_a?(Importer::PreviewFile) || attachment_record.is_a?(Importer::ImportFile)
  end

  def path_segments
    @path_segments ||= params[:path].to_s.split("/")
  end
end
