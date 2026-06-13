require_relative "../../test_helper"

class ImporterValidationI18nTest < ActiveSupport::TestCase
  test "custom validations use symbolic errors" do
    invalid_records.each do |record, attribute|
      record.valid?

      assert_equal :invalid, record.errors.details.fetch(attribute).first.fetch(:error), record.class.name
    end
  end

  test "resident content ownership validations use symbolic errors" do
    invalid_owner_records.each do |record|
      record.valid?

      assert_equal :blank, record.errors.details.fetch(:resident).first.fetch(:error), record.class.name
    end
  end

  private

  def invalid_records
    [
      [ Importer::Preview.new(mode: "shared_library", source: "game_master_5_xml", status: "parsing"), :mode ],
      [ Importer::Preview.new(mode: "resident_content", source: "game_master_5_xml", status: "done"), :status ],
      [ Importer::Import.new(mode: "shared_library", source: "game_master_5_xml", status: "queued"), :mode ],
      [ Importer::Import.new(mode: "resident_content", source: "game_master_5_xml", status: "done"), :status ],
      [ Importer::PreviewFile.new(detected_kind: "spellbook"), :detected_kind ],
      [ Importer::PreviewFile.new(detected_kind: "compendium", override_kind: "spellbook"), :override_kind ],
      [ Importer::ImportFile.new(kind: "spellbook", parse_status: "pending"), :kind ],
      [ Importer::ImportFile.new(kind: "compendium", parse_status: "done"), :parse_status ],
      [ Importer::ImportResult.new(entity_type: "monster", entity_name: "Goblin", outcome: "done"), :outcome ]
    ]
  end

  def invalid_owner_records
    [
      Importer::Preview.new(mode: "resident_content", source: "game_master_5_xml", status: "parsing"),
      Importer::Import.new(mode: "resident_content", source: "game_master_5_xml", status: "queued")
    ]
  end
end
