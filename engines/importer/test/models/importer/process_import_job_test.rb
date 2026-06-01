require_relative "../../test_helper"

class ImporterProcessImportJobTest < ActiveSupport::TestCase
  test "admin stock compendium import creates stock records and results" do
    import = import_for("sample_compendium.xml", mode: Importer::Preview::ADMIN_STOCK)

    assert_difference("Entitybuilder::StockCreature.count", 2) do
      assert_difference("Rulebuilder::StockItem.count", 1) do
        assert_difference("Rulebuilder::StockSpell.count", 1) do
          assert_difference("Rulebuilder::StockRule.count", 4) do
            Importer::ProcessImportJob.perform_now(import.id)
          end
        end
      end
    end

    assert_equal "succeeded", import.reload.status
    assert_equal 8, import.import_results.created.count
    assert_equal "Residents", Entitybuilder::StockCreature.find_by!(name: "Goblin").privacy
    assert_equal "Residents", Entitybuilder::StockCreature.find_by!(name: "Goblin").sheet_privacy
    assert_equal "Backgrounds", Rulebuilder::StockRule.find_by!(name: "Sailor").rule_type
    assert_equal "Class", Rulebuilder::StockRule.find_by!(name: "Fighter").rule_type
  end

  test "resident compendium import creates resident records" do
    import = import_for("sample_compendium.xml", mode: Importer::Preview::RESIDENT_CONTENT)

    assert_difference("Entitybuilder::ResidentCreature.count", 2) do
      assert_difference("Rulebuilder::ResidentItem.count", 1) do
        assert_difference("Rulebuilder::ResidentSpell.count", 1) do
          assert_difference("Rulebuilder::ResidentRule.count", 4) do
            Importer::ProcessImportJob.perform_now(import.id)
          end
        end
      end
    end

    assert_equal "succeeded", import.reload.status
    assert_equal residents(:razune), Entitybuilder::ResidentCreature.find_by!(name: "Goblin").resident
    assert_equal "Private", Entitybuilder::ResidentCreature.find_by!(name: "Goblin").privacy
    assert_nil Rulebuilder::ResidentItem.find_by!(name: "Longsword").category
    assert_equal "Species", Rulebuilder::ResidentRule.find_by!(name: "Elf").rule_type
  end

  test "resident campaign import creates campaign records and skips nothing" do
    import = import_for("sample_campaign.xml", mode: Importer::Preview::RESIDENT_CONTENT)

    assert_difference("Campaignmanager::Campaign.count", 1) do
      assert_difference("Storybuilder::ResidentAdventure.count", 1) do
        assert_difference("Storybuilder::Page.count", 1) do
          assert_difference("Campaignmanager::GameMasterNote.count", 1) do
            assert_difference("Entitybuilder::ResidentCharacter.count", 1) do
              assert_difference("Entitybuilder::ResidentNpc.count", 1) do
                Importer::ProcessImportJob.perform_now(import.id)
              end
            end
          end
        end
      end
    end

    assert_equal "succeeded", import.reload.status
    assert_equal residents(:razune), Campaignmanager::Campaign.find_by!(name: "Red Hand").resident
    assert_equal "Road Ambush", Storybuilder::Page.find_by!(name: "Road Ambush").name
    assert_equal "created", import.import_results.find_by!(entity_type: "pc").outcome
  end

  test "admin stock campaign import creates stock adventure records and skips pcs" do
    import = import_for("sample_campaign.xml", mode: Importer::Preview::ADMIN_STOCK)

    assert_difference("Storybuilder::StockAdventure.count", 1) do
      assert_difference("Storybuilder::Page.count", 2) do
        assert_difference("Entitybuilder::StockNpc.count", 1) do
          Importer::ProcessImportJob.perform_now(import.id)
        end
      end
    end

    assert_equal "partial", import.reload.status
    assert_equal "Residents", Storybuilder::StockAdventure.find_by!(name: "Elsir Vale").privacy
    assert_equal "no stock character target", import.import_results.find_by!(entity_type: "pc").reason
  end

  test "admin stock campaign import creates one stock adventure per imported adventure" do
    import = import_for("sample_multi_adventure_campaign.xml", mode: Importer::Preview::ADMIN_STOCK)

    assert_difference("Storybuilder::StockAdventure.count", 2) do
      assert_difference("Storybuilder::Page.count", 2) do
        Importer::ProcessImportJob.perform_now(import.id)
      end
    end

    assert_equal "succeeded", import.reload.status
    assert_equal "Residents", Storybuilder::StockAdventure.find_by!(name: "Elsir Vale").privacy
    assert_equal "Residents", Storybuilder::StockAdventure.find_by!(name: "Witchwood").privacy
    assert_equal "Elsir Vale", Storybuilder::Page.find_by!(name: "Road Ambush").adventure.name
    assert_equal "Witchwood", Storybuilder::Page.find_by!(name: "Forest Shrine").adventure.name
  end

  test "resident campaign reimport skips existing records" do
    Importer::ProcessImportJob.perform_now(import_for("sample_campaign.xml", mode: Importer::Preview::RESIDENT_CONTENT).id)
    import = import_for("sample_campaign.xml", mode: Importer::Preview::RESIDENT_CONTENT)

    assert_no_difference("Campaignmanager::Campaign.count") do
      assert_no_difference("Storybuilder::ResidentAdventure.count") do
        assert_no_difference("Storybuilder::Page.count") do
          assert_no_difference("Campaignmanager::GameMasterNote.count") do
            assert_no_difference("Entitybuilder::ResidentCharacter.count") do
              assert_no_difference("Entitybuilder::ResidentNpc.count") do
                Importer::ProcessImportJob.perform_now(import.id)
              end
            end
          end
        end
      end
    end

    assert_equal "succeeded", import.reload.status
    assert_equal [ "already exists" ], import.import_results.skipped.distinct.pluck(:reason)
    assert_equal %w[adventure campaign encounter note npc pc], import.import_results.skipped.order(:entity_type).pluck(:entity_type)
  end

  test "admin stock campaign reimport skips existing records" do
    Importer::ProcessImportJob.perform_now(import_for("sample_campaign.xml", mode: Importer::Preview::ADMIN_STOCK).id)
    import = import_for("sample_campaign.xml", mode: Importer::Preview::ADMIN_STOCK)

    assert_no_difference("Storybuilder::StockAdventure.count") do
      assert_no_difference("Storybuilder::Page.count") do
        assert_no_difference("Entitybuilder::StockNpc.count") do
          Importer::ProcessImportJob.perform_now(import.id)
        end
      end
    end

    assert_equal "partial", import.reload.status
    assert_equal [ "already exists", "no stock character target" ], import.import_results.order(:reason).distinct.pluck(:reason)
    assert_equal %w[adventure encounter note npc], import.import_results.where(reason: "already exists").order(:entity_type).pluck(:entity_type)
  end

  test "reimport succeeds with already exists skips" do
    Importer::ProcessImportJob.perform_now(import_for("sample_compendium.xml", mode: Importer::Preview::ADMIN_STOCK).id)
    import = import_for("sample_compendium.xml", mode: Importer::Preview::ADMIN_STOCK)

    Importer::ProcessImportJob.perform_now(import.id)

    assert_equal "succeeded", import.reload.status
    assert_equal 8, import.import_results.skipped.count
    assert_equal [ "already exists" ], import.import_results.skipped.distinct.pluck(:reason)
  end

  test "unsupported imports do not report success" do
    import = import_for_kind("unsupported", mode: Importer::Preview::RESIDENT_CONTENT)

    Importer::ProcessImportJob.perform_now(import.id)

    assert_equal "partial", import.reload.status
    assert_equal "failed", import.import_files.first.parse_status
    assert_equal [ "unsupported file kind" ], import.import_results.failed.distinct.pluck(:reason)
  end

  test "standalone pc imports do not report success before support exists" do
    import = import_for_kind("pc", mode: Importer::Preview::RESIDENT_CONTENT)

    Importer::ProcessImportJob.perform_now(import.id)

    assert_equal "partial", import.reload.status
    assert_equal "failed", import.import_files.first.parse_status
    assert_equal [ "unsupported file kind" ], import.import_results.failed.distinct.pluck(:reason)
  end

  test "imports without preview files do not report success" do
    import = Importer::Import.create!(resident: residents(:razune), mode: Importer::Preview::RESIDENT_CONTENT,
                                      source: Importer::Preview::GAME_MASTER_5_XML, status: Importer::Import::QUEUED)

    Importer::ProcessImportJob.perform_now(import.id)

    assert_equal "failed", import.reload.status
    assert_equal({ "error" => "no import files available" }, import.summary)
  end

  private

  def import_for(file_name, mode:)
    preview = preview_for(mode)
    preview.add_uploads([ uploaded_file(file_name) ])
    Importer::Import.create!(resident: preview.resident, mode: preview.mode, source: preview.source,
                             status: Importer::Import::QUEUED, preview: preview)
  end

  def import_for_kind(kind, mode:)
    import = Importer::Import.create!(resident: resident_for(mode), mode: mode, source: Importer::Preview::GAME_MASTER_5_XML,
                                      status: Importer::Import::QUEUED)
    File.open(importer_fixture_file("sample_compendium.xml")) do |file|
      import.import_files.create!(kind: kind, parse_status: "pending", file: file)
    end
    import
  end

  def preview_for(mode)
    Importer::Preview.create!(resident: resident_for(mode), mode: mode, source: Importer::Preview::GAME_MASTER_5_XML,
                              status: "parsing")
  end

  def resident_for(mode)
    residents(:razune) if mode == Importer::Preview::RESIDENT_CONTENT
  end

  def uploaded_file(file_name)
    Rack::Test::UploadedFile.new(importer_fixture_file(file_name), "text/xml")
  end
end
