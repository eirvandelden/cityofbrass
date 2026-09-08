class PaperclipFilesController < ApplicationController
  def show
    return redirect_to(legacy_gallery_redirect_path, status: :moved_permanently) if legacy_gallery_redirect_path

    requested_file = requested_storage_file
    return head :not_found unless requested_file
    return head :not_found unless attachment_record
    style = requested_attachment_style(requested_file)
    return head :not_found unless style
    file = readable_attachment_file(requested_file)
    return head :not_found unless file
    return head :forbidden unless allowed_to_show_importer_attachment?

    send_file file, disposition: "inline"
  end

  private

  def legacy_gallery_redirect_path
    case path_segments
    in [ "gallery", "faq-images", id, style_with_extension ]
      "/attachments/gallery/faq_images/#{id}/#{style_from(style_with_extension)}"
    in [ "gallery", "stock-images", id, style_with_extension ]
      "/attachments/gallery/stock_images/#{id}/#{style_from(style_with_extension)}"
    in [ "gallery", "map-images", id, style_with_extension ]
      "/attachments/gallery/map_images/#{id}/#{style_from(style_with_extension)}"
    in [ "gallery", "residents", _, _, _, _resident_id, "images", id, style_with_extension ]
      "/attachments/gallery/resident_images/#{id}/#{style_from(style_with_extension)}"
    else
      nil
    end
  end

  def style_from(style_with_extension)
    File.basename(style_with_extension, ".*")
  end

  def storage_path
    Rails.root.join("storage", "paperclip")
  end

  def requested_storage_file
    file = storage_path.join(params[:path]).cleanpath
    return unless file.to_s.start_with?("#{storage_path}/")

    file
  end

  def attachment_record
    @attachment_record ||= importer_attachment_record
  end

  def requested_attachment_style(file)
    attachment_styles.find { |style| clean_attachment_path(style) == file.to_s }
  end

  def attachment_styles
    attachment_record.file.styles.keys + [ :original ]
  end

  def readable_attachment_file(requested_file)
    requested_file if requested_file.file?
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

  def path_segments
    @path_segments ||= params[:path].to_s.split("/")
  end
end
