require "test_helper"

class PaperclipFilesTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "does not serve unrecognized gallery files from storage" do
    file = Rails.root.join("storage", "paperclip", "gallery", "test.txt")
    FileUtils.mkdir_p(file.dirname)
    File.write(file, "paperclip")

    get "/paperclip/gallery/test.txt"

    assert_response :not_found
  ensure
    FileUtils.rm_f(file) if file
  end

  test "serves importer preview files to the owner" do
    preview = Importer::Preview.create!(resident: residents(:razune), mode: Importer::Preview::RESIDENT_CONTENT,
                                        source: Importer::Preview::GAME_MASTER_5_XML, status: "parsing")
    preview.add_uploads([ Rack::Test::UploadedFile.new(importer_fixture_file, "text/xml") ])
    preview_file = preview.preview_files.first
    sign_in users(:dan)

    get preview_file.file.url

    assert_response :success
    assert_includes response.body, "<compendium"
  end

  test "does not serve importer preview files to anonymous users" do
    preview = Importer::Preview.create!(resident: residents(:razune), mode: Importer::Preview::RESIDENT_CONTENT,
                                        source: Importer::Preview::GAME_MASTER_5_XML, status: "parsing")
    preview.add_uploads([ Rack::Test::UploadedFile.new(importer_fixture_file, "text/xml") ])

    get preview.preview_files.first.file.url

    assert_response :forbidden
  end

  test "does not serve arbitrary files in an importer preview file directory" do
    preview = Importer::Preview.create!(resident: residents(:razune), mode: Importer::Preview::RESIDENT_CONTENT,
                                        source: Importer::Preview::GAME_MASTER_5_XML, status: "parsing")
    preview.add_uploads([ Rack::Test::UploadedFile.new(importer_fixture_file, "text/xml") ])
    preview_file = preview.preview_files.first
    path = "importer/previews/#{preview_file.id}/not_the_uploaded_file.xml"
    file = Rails.root.join("storage", "paperclip", path)
    FileUtils.mkdir_p(file.dirname)
    File.write(file, "<compendium />")
    sign_in users(:dan)

    get "/paperclip/#{path}"

    assert_response :not_found
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

  private

  def importer_fixture_file
    Importer::Engine.root.join("test/fixtures/files/importer/sample_compendium.xml")
  end
end
