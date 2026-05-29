require_relative "../../test_helper"

class ImporterImportTest < ActiveSupport::TestCase
  test "resident content imports require a resident" do
    import = Importer::Import.new(mode: "resident_content", source: "game_master_5_xml", status: "queued")

    assert_not import.valid?
    assert_includes import.errors[:resident], "can't be blank"
  end

  test "admin stock imports do not require a resident" do
    import = Importer::Import.new(mode: "admin_stock", source: "game_master_5_xml", status: "queued")

    assert import.valid?, import.errors.full_messages.to_sentence
  end

  test "rejects unknown import modes" do
    import = Importer::Import.new(mode: "shared_library", source: "game_master_5_xml", status: "queued")

    assert_not import.valid?
    assert_includes import.errors[:mode], "is not valid"
  end
end
