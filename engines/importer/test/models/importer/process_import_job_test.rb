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
    assert_equal "Race", Rulebuilder::ResidentRule.find_by!(name: "Elf").rule_type
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

  test "reimport succeeds with already exists skips" do
    Importer::ProcessImportJob.perform_now(import_for("sample_compendium.xml", mode: Importer::Preview::ADMIN_STOCK).id)
    import = import_for("sample_compendium.xml", mode: Importer::Preview::ADMIN_STOCK)

    Importer::ProcessImportJob.perform_now(import.id)

    assert_equal "succeeded", import.reload.status
    assert_equal 8, import.import_results.skipped.count
    assert_equal [ "already exists" ], import.import_results.skipped.distinct.pluck(:reason)
  end

  private

  def import_for(file_name, mode:)
    preview = preview_for(mode)
    preview.add_uploads([ uploaded_file(file_name) ])
    Importer::Import.create!(resident: preview.resident, mode: preview.mode, source: preview.source,
                             status: Importer::Import::QUEUED, preview: preview)
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
