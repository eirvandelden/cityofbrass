require "test_helper"

class PaperclipFilesTest < ActionDispatch::IntegrationTest
  test "serves gallery paperclip files from storage" do
    file = Rails.root.join("storage", "paperclip", "gallery", "test.txt")
    FileUtils.mkdir_p(file.dirname)
    File.write(file, "paperclip")

    get "/paperclip/gallery/test.txt"

    assert_response :success
    assert_equal "paperclip", response.body
  ensure
    FileUtils.rm_f(file) if file
  end

  test "does not serve files outside gallery storage" do
    file = Rails.root.join("storage", "paperclip", "gallery-private", "secret.txt")
    FileUtils.mkdir_p(file.dirname)
    File.write(file, "secret")

    get "/paperclip/gallery/../gallery-private/secret.txt"

    assert_response :not_found
  ensure
    FileUtils.rm_f(file) if file
  end
end
