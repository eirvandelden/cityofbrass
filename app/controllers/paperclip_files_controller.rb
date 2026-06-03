class PaperclipFilesController < ApplicationController
  def show
    file = storage_path.join(params[:path]).cleanpath
    return head :not_found unless file.to_s.start_with?("#{storage_path}/")
    return head :not_found unless file.file?

    send_file file, disposition: "inline"
  end

  private

  def storage_path
    Rails.root.join("storage", "paperclip", "gallery")
  end
end
