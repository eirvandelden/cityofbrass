require_relative "../../test_helper"

class ImporterPreviewTest < ActiveSupport::TestCase
  test "add_uploads requires at least one file" do
    preview = Importer::Preview.create!(resident: residents(:razune), mode: "resident_content", source: "game_master_5_xml",
                                        status: "parsing")

    assert_not preview.add_uploads(nil)
    assert_includes preview.errors[:base], "must include at least one file"
    assert_equal "parsing", preview.reload.status
    assert_equal 0, preview.preview_files.count
  end

  test "add_uploads accepts xml files regardless of content type" do
    preview = Importer::Preview.create!(resident: residents(:razune), mode: "resident_content", source: "game_master_5_xml",
                                        status: "parsing")

    assert preview.add_uploads([ octet_stream_xml_upload ])
    assert_equal "ready", preview.reload.status
    assert_equal 1, preview.preview_files.count
  end

  test "add_uploads rejects non-xml content regardless of content type" do
    preview = Importer::Preview.create!(resident: residents(:razune), mode: "resident_content", source: "game_master_5_xml",
                                        status: "parsing")
    file = octet_stream_plain_text_upload

    assert_not preview.add_uploads([ file ])
    assert_includes preview.errors[:base], "must be an XML file"
    assert_equal "parsing", preview.reload.status
    assert_equal 0, preview.preview_files.count
  ensure
    FileUtils.rm_f(file&.path)
  end

  test "resident content previews require a resident" do
    preview = Importer::Preview.new(mode: "resident_content", source: "game_master_5_xml", status: "parsing")

    assert_not preview.valid?
    assert_includes preview.errors[:resident], "can't be blank"
  end

  test "admin stock previews do not require a resident" do
    preview = Importer::Preview.new(mode: "admin_stock", source: "game_master_5_xml", status: "parsing")

    assert preview.valid?, preview.errors.full_messages.to_sentence
  end

  private

  def octet_stream_xml_upload
    Rack::Test::UploadedFile.new(importer_fixture_file("sample_compendium.xml"), "application/octet-stream")
  end

  def octet_stream_plain_text_upload
    file = Tempfile.new([ "plain-import", ".txt" ])
    file.write("not xml")
    file.rewind
    Rack::Test::UploadedFile.new(file.path, "application/octet-stream")
  ensure
    file&.close
  end
end
