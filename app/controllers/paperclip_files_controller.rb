class PaperclipFilesController < ApplicationController
  def show
    requested_file = requested_storage_file
    return head :not_found unless requested_file
    return head :not_found unless attachment_record
    style = requested_attachment_style(requested_file)
    return head :not_found unless style
    file = readable_attachment_file(requested_file, style)
    return head :not_found unless file
    return head :forbidden unless allowed_to_show_attachment?

    send_file file, disposition: "inline"
  end

  private

  def storage_path
    Rails.root.join("storage", "paperclip")
  end

  def requested_storage_file
    file = storage_path.join(params[:path]).cleanpath
    return unless file.to_s.start_with?("#{storage_path}/")

    file
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
      Gallery::StockImage.find_by(id: id)
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
    when Gallery::FaqImage
      admin_signed_in?
    when Gallery::ResidentImage
      admin_signed_in? || attachment_record.resident.user_id == current_user&.id
    else
      false
    end
  end

  def requested_attachment_style(file)
    attachment_styles.find { |style| clean_attachment_path(style) == file.to_s }
  end

  def attachment_styles
    attachment_record.file.styles.keys + [ :original ]
  end

  def readable_attachment_file(requested_file, style)
    return requested_file if requested_file.file?

    legacy_gallery_attachment_path(style)&.then { |file| file if file.file? }
  end

  def clean_attachment_path(style)
    Pathname.new(attachment_record.file.path(style)).cleanpath.to_s
  end

  def legacy_gallery_attachment_path(style)
    return unless gallery_attachment?

    Rails.root.join(*legacy_gallery_attachment_segments(style)).cleanpath
  end

  def legacy_gallery_attachment_segments(style)
    case attachment_record
    when Gallery::ResidentImage
      [ "gallery", "residents", *resident_part_id, attachment_record.resident_id, "images", attachment_record.id,
        "#{style}.#{attachment_extension}" ]
    when Gallery::StockImage
      [ "gallery", "stock-images", attachment_record.id, "#{style}.#{attachment_extension}" ]
    when Gallery::MapImage
      [ "gallery", "map-images", attachment_record.id, "#{style}.#{attachment_extension}" ]
    when Gallery::FaqImage
      [ "gallery", "faq-images", attachment_record.id, "#{style}.#{attachment_extension}" ]
    end
  end

  def gallery_attachment?
    attachment_record.is_a?(Gallery::Image)
  end

  def resident_part_id
    attachment_record.resident_id[0, 3].chars
  end

  def attachment_extension
    File.extname(attachment_record.file_file_name).delete_prefix(".")
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
