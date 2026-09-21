require "test_helper"

class PaperclipFilesTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

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

  test "redirects a legacy faq image url to the new attachment url" do
    faq_image = gallery_images(:faq_one)

    get "/paperclip/gallery/faq-images/#{faq_image.id}/thumb.png"

    assert_redirected_to "/attachments/gallery/faq_images/#{faq_image.id}/thumb"
    assert_equal 301, response.status
  end

  test "redirects a legacy stock image url to the new attachment url" do
    stock_image = gallery_images(:stock_one)

    get "/paperclip/gallery/stock-images/#{stock_image.id}/original.jpg"

    assert_redirected_to "/attachments/gallery/stock_images/#{stock_image.id}/original"
    assert_equal 301, response.status
  end

  test "redirects a legacy map image url to the new attachment url" do
    map_image = gallery_images(:map_one)

    get "/paperclip/gallery/map-images/#{map_image.id}/medium.png"

    assert_redirected_to "/attachments/gallery/map_images/#{map_image.id}/medium"
    assert_equal 301, response.status
  end

  test "redirects a legacy resident image url to the new attachment url" do
    resident_image = gallery_images(:resident_one)
    resident_id = resident_image.resident_id
    part_id = resident_id[0, 3].chars.join("/")

    get "/paperclip/gallery/residents/#{part_id}/#{resident_id}/images/#{resident_image.id}/thumb.png"

    assert_redirected_to "/attachments/gallery/resident_images/#{resident_image.id}/thumb"
    assert_equal 301, response.status
  end

  test "following a legacy faq image redirect as a non-admin is still refused" do
    faq_image = gallery_images(:faq_one)
    sign_in users(:dan)

    get "/paperclip/gallery/faq-images/#{faq_image.id}/thumb.png"
    follow_redirect!

    assert_response :forbidden
  end

  private

  def importer_fixture_file
    Importer::Engine.root.join("test/fixtures/files/importer/sample_compendium.xml")
  end
end
