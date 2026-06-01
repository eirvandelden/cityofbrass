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

  test "resident content previews require a resident" do
    preview = Importer::Preview.new(mode: "resident_content", source: "game_master_5_xml", status: "parsing")

    assert_not preview.valid?
    assert_includes preview.errors[:resident], "can't be blank"
  end

  test "admin stock previews do not require a resident" do
    preview = Importer::Preview.new(mode: "admin_stock", source: "game_master_5_xml", status: "parsing")

    assert preview.valid?, preview.errors.full_messages.to_sentence
  end
end
