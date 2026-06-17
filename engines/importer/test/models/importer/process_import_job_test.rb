require_relative "../../test_helper"

class ImporterProcessImportJobTest < ActiveSupport::TestCase
  test "process import job uses the imports queue" do
    assert_equal "imports", Importer::ProcessImportJob.queue_name
  end

  test "admin stock compendium import creates stock records and results" do
    import = import_for("sample_compendium.xml", mode: Importer::Preview::ADMIN_STOCK)

    assert_difference("Entitybuilder::StockCreature.count", 2) do
      assert_difference("Rulebuilder::StockItem.count", 1) do
        assert_difference("Rulebuilder::StockSpell.count", 1) do
          assert_difference("Rulebuilder::StockRule.count", 5) do
            Importer::ProcessImportJob.perform_now(import.id)
          end
        end
      end
    end

    assert_equal "succeeded", import.reload.status
    assert_equal 9, import.import_results.created.count
    assert_equal "Residents", Entitybuilder::StockCreature.find_by!(name: "Goblin").privacy
    assert_equal "Residents", Entitybuilder::StockCreature.find_by!(name: "Goblin").sheet_privacy
    assert_equal "Backgrounds", Rulebuilder::StockRule.find_by!(name: "Sailor").rule_type
    assert_equal "Class", Rulebuilder::StockRule.find_by!(name: "Fighter").rule_type
    assert_equal "Subclass", Rulebuilder::StockRule.find_by!(name: "Champion").rule_type
  end

  test "resident compendium import creates resident records" do
    import = import_for("sample_compendium.xml", mode: Importer::Preview::RESIDENT_CONTENT)

    assert_difference("Entitybuilder::ResidentCreature.count", 2) do
      assert_difference("Rulebuilder::ResidentItem.count", 1) do
        assert_difference("Rulebuilder::ResidentSpell.count", 1) do
          assert_difference("Rulebuilder::ResidentRule.count", 5) do
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
    assert_equal "Subclass", Rulebuilder::ResidentRule.find_by!(name: "Champion").rule_type
  end

  test "resident campaign import creates campaign records and skips nothing" do
    import = import_for("sample_campaign.xml", mode: Importer::Preview::RESIDENT_CONTENT)

    assert_difference("Campaignmanager::Campaign.count", 1) do
      assert_difference("Storybuilder::ResidentAdventure.count", 1) do
        assert_difference("Storybuilder::Page.count", 1) do
          assert_difference("Campaignmanager::GameMasterNote.count", 7) do
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

  test "campaign import uses file name when campaign name is blank and reads note titles" do
    import = import_for_kind_with_file("blank_campaign_titles.xml", kind: "campaign",
                                                                    mode: Importer::Preview::RESIDENT_CONTENT)

    assert_difference("Campaignmanager::Campaign.count", 1) do
      assert_difference("Storybuilder::ResidentAdventure.count", 1) do
        assert_difference("Storybuilder::Page.count", 1) do
          Importer::ProcessImportJob.perform_now(import.id)
        end
      end
    end

    assert_equal "succeeded", import.reload.status
    assert Campaignmanager::Campaign.exists?(name: "blank campaign titles")
    assert Storybuilder::Page.exists?(name: "Session 1: Bridge Trouble")
    assert_equal "parsed", import.import_files.first.parse_status
  end

  test "resident campaign import uses npc label when npc name is blank" do
    import = import_for_kind_with_file("label_only_npc_campaign.xml", kind: "campaign",
                                                                    mode: Importer::Preview::RESIDENT_CONTENT)

    assert_difference("Entitybuilder::ResidentNpc.count", 1) do
      Importer::ProcessImportJob.perform_now(import.id)
    end

    assert_equal "succeeded", import.reload.status
    assert import.import_results.failed.none?
    assert Entitybuilder::ResidentNpc.exists?(name: "Delora Zann (owner stable)", resident: residents(:razune))
  end

  test "resident campaign import truncates long note titles to local page name limit" do
    import = import_for_kind_with_file("long_note_title_campaign.xml", kind: "campaign",
                                                                    mode: Importer::Preview::RESIDENT_CONTENT)

    assert_difference("Storybuilder::Page.count", 1) do
      Importer::ProcessImportJob.perform_now(import.id)
    end

    assert_equal "succeeded", import.reload.status
    assert import.import_results.failed.none?
    assert Storybuilder::Page.exists?(
      name: 'Session 5: Next up in theaters: "The Girl and her Eyeball Famili'
    )
  end

  test "resident campaign import turns campaign-level notes and encounters into adventure pages" do
    import = import_for_kind_with_file("campaign_level_pages.xml", kind: "campaign",
                                                                   mode: Importer::Preview::RESIDENT_CONTENT)

    assert_difference("Campaignmanager::Campaign.count", 1) do
      assert_difference("Storybuilder::ResidentAdventure.count", 1) do
        assert_difference("Storybuilder::Page.count", 2) do
          Importer::ProcessImportJob.perform_now(import.id)
        end
      end
    end

    campaign = Campaignmanager::Campaign.find_by!(name: "Page Only Campaign")
    adventure = campaign.adventures.find_by!(name: "Page Only Campaign")

    assert_equal "succeeded", import.reload.status
    assert adventure.pages.exists?(name: "0. Introduction")
    assert adventure.pages.exists?(name: "Upper Floor 1. Keep Out!")
    assert_not campaign.game_master_notes.exists?(name: "0. Introduction")
  end

  test "resident campaign import creates encounter pages and embedded content" do
    import = import_for("sample_campaign_with_embedded_content.xml", mode: Importer::Preview::RESIDENT_CONTENT)

    assert_difference("Campaignmanager::Campaign.count", 1) do
      assert_difference("Storybuilder::ResidentAdventure.count", 1) do
        assert_difference("Storybuilder::Page.count", 2) do
          assert_difference("Entitybuilder::ResidentCreature.count", 1) do
            assert_difference("Rulebuilder::ResidentItem.count", 1) do
              Importer::ProcessImportJob.perform_now(import.id)
            end
          end
        end
      end
    end

    assert_equal "succeeded", import.reload.status
    assert_equal %w[adventure campaign encounter item monster], import.import_results.created.order(:entity_type).distinct.pluck(:entity_type)
    assert Storybuilder::Page.exists?(name: "Silent Guardians")
    assert Storybuilder::Page.exists?(name: "Dark Haunts")
    assert Entitybuilder::ResidentCreature.exists?(name: "Brute CR1", resident: residents(:razune))
    assert Rulebuilder::ResidentItem.exists?(name: "Symbol Of Life", resident: residents(:razune))
    assert Storybuilder::Page.find_by!(name: "Silent Guardians").notables.exists?(entity: Entitybuilder::ResidentCreature.find_by!(name: "Brute CR1"))
  end

  test "resident campaign import creates provenance game master notes for created records" do
    import = import_for("sample_campaign.xml", mode: Importer::Preview::RESIDENT_CONTENT)

    assert_difference("Campaignmanager::GameMasterNote.count", 7) do
      Importer::ProcessImportJob.perform_now(import.id)
    end

    campaign = Campaignmanager::Campaign.find_by!(name: "Red Hand")
    notes = imported_provenance_notes(campaign)

    assert_equal 6, notes.count
    notes.each do |note|
      assert_includes note.full_description, "Game Master 5 XML"
      assert_includes note.full_description, "/imports/#{import.id}"
      assert_match(/\d{4}-\d{2}-\d{2}/, note.full_description)
    end

    npc = Entitybuilder::ResidentNpc.find_by!(name: "Captain Soranna")
    npc_note = notes.find { |note| note.full_description.include?("Captain Soranna") }

    assert npc_note.notables.exists?(entity: npc)
  end

  test "resident campaign import links created creatures and npcs to the created adventure" do
    import = import_for("sample_campaign_with_embedded_content.xml", mode: Importer::Preview::RESIDENT_CONTENT)

    assert_difference("Storybuilder::Notable.count", 3) do
      Importer::ProcessImportJob.perform_now(import.id)
    end

    adventure = Storybuilder::ResidentAdventure.find_by!(name: "Shade Vault")
    creature = Entitybuilder::ResidentCreature.find_by!(name: "Brute CR1")

    assert adventure.notables.exists?(entity: creature)

    import = import_for("sample_campaign.xml", mode: Importer::Preview::RESIDENT_CONTENT)
    Importer::ProcessImportJob.perform_now(import.id)

    adventure = Storybuilder::ResidentAdventure.find_by!(name: "Elsir Vale")
    npc = Entitybuilder::ResidentNpc.find_by!(name: "Captain Soranna")

    assert adventure.notables.exists?(entity: npc)
  end

  test "file failure does not leave later files pending" do
    import = import_for_multiple(
      { file: "blank_item_compendium.xml", kind: "compendium" },
      { file: "sample_campaign.xml", kind: "campaign" },
      mode: Importer::Preview::RESIDENT_CONTENT
    )

    assert_difference("Campaignmanager::Campaign.count", 1) do
      Importer::ProcessImportJob.perform_now(import.id)
    end

    assert_equal "partial", import.reload.status
    assert_equal %w[failed parsed], import.import_files.order(:created_at).pluck(:parse_status)
    assert import.import_results.failed.exists?(entity_type: "compendium", entity_name: "blank_item_compendium.xml")
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

  test "resident multi adventure campaign links every adventure to the campaign" do
    import = import_for("sample_multi_adventure_campaign.xml", mode: Importer::Preview::RESIDENT_CONTENT)

    assert_difference("Campaignmanager::Campaign.count", 1) do
      assert_difference("Storybuilder::ResidentAdventure.count", 2) do
        assert_difference("Storybuilder::Page.count", 2) do
          Importer::ProcessImportJob.perform_now(import.id)
        end
      end
    end

    campaign = Campaignmanager::Campaign.find_by!(name: "Red Hand")

    assert_equal "succeeded", import.reload.status
    assert_equal [ "Elsir Vale", "Witchwood" ], campaign.adventures.order(:name).pluck(:name)
    assert_equal 1, campaign.campaign_adventure_joins.where(active: true).count
  end

  test "resident campaign reimport replaces imported records" do
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
    assert import.import_results.skipped.none?
    assert_equal %w[adventure campaign encounter note npc pc], import.import_results.replaced.order(:entity_type).pluck(:entity_type)
  end

  test "admin stock campaign reimport replaces imported records" do
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
    assert import.import_results.where(reason: "already exists").none?
    assert_equal [ "no stock character target" ], import.import_results.where.not(reason: nil).distinct.pluck(:reason)
    assert_equal %w[adventure encounter note npc], import.import_results.replaced.order(:entity_type).pluck(:entity_type)
  end

  test "reimport succeeds with replacements for previously imported records" do
    Importer::ProcessImportJob.perform_now(import_for("sample_compendium.xml", mode: Importer::Preview::ADMIN_STOCK).id)
    import = import_for("sample_compendium.xml", mode: Importer::Preview::ADMIN_STOCK)

    Importer::ProcessImportJob.perform_now(import.id)

    assert_equal "succeeded", import.reload.status
    assert_equal 9, import.import_results.replaced.count
    assert import.import_results.skipped.none?
  end

  test "import ignores same-name records from a different ruleset" do
    Entitybuilder::StockCreature.create!(name: "Goblin", core_rules: "pf1e", privacy: "Residents",
                                         sheet_privacy: "Residents")
    import = import_for("sample_compendium.xml", mode: Importer::Preview::ADMIN_STOCK)

    assert_difference("Entitybuilder::StockCreature.where(name: 'Goblin', core_rules: 'dnd5e').count", 1) do
      Importer::ProcessImportJob.perform_now(import.id)
    end

    result = import.reload.import_results.find_by!(entity_type: "monster", entity_name: "Goblin")
    assert_equal "created", result.outcome
  end

  test "unsupported imports do not report success" do
    import = import_for_kind("unsupported", mode: Importer::Preview::RESIDENT_CONTENT)

    Importer::ProcessImportJob.perform_now(import.id)

    assert_equal "partial", import.reload.status
    assert_equal "failed", import.import_files.first.parse_status
    assert_equal [ "unsupported file kind" ], import.import_results.failed.distinct.pluck(:reason)
  end

  test "unsupported malformed XML records a file failure instead of failing the whole import" do
    import = import_for_kind_with_file("malformed.xml", kind: "unsupported", mode: Importer::Preview::RESIDENT_CONTENT)

    Importer::ProcessImportJob.perform_now(import.id)

    assert_equal "partial", import.reload.status
    assert_equal "failed", import.import_files.first.parse_status
    assert_equal [ "unsupported file kind" ], import.import_results.failed.distinct.pluck(:reason)
  end

  test "standalone pc file kind is parsed (not treated as unsupported)" do
    import = import_for_kind("pc", mode: Importer::Preview::RESIDENT_CONTENT)

    Importer::ProcessImportJob.perform_now(import.id)

    assert_equal "succeeded", import.reload.status
    assert_equal "parsed", import.import_files.first.parse_status
    assert import.import_results.failed.none?
  end

  test "imports without preview files do not report success" do
    import = Importer::Import.create!(resident: residents(:razune), mode: Importer::Preview::RESIDENT_CONTENT,
                                      source: Importer::Preview::GAME_MASTER_5_XML, status: Importer::Import::QUEUED)

    Importer::ProcessImportJob.perform_now(import.id)

    assert_equal "failed", import.reload.status
    assert_equal({ "error" => "no import files available" }, import.summary)
  end

  test "resident compendium + campaign import links encounter combatants to creatures via notables" do
    import = import_for_multiple(
      { file: "sample_compendium.xml", kind: "compendium" },
      { file: "sample_campaign.xml", kind: "campaign" },
      mode: Importer::Preview::RESIDENT_CONTENT
    )

    assert_difference("Storybuilder::Notable.count", 2) do
      Importer::ProcessImportJob.perform_now(import.id)
    end

    page = Storybuilder::Page.find_by!(name: "Road Ambush")
    adventure = Storybuilder::ResidentAdventure.find_by!(name: "Elsir Vale")
    goblin = Entitybuilder::ResidentCreature.find_by!(name: "Goblin")
    npc = Entitybuilder::ResidentNpc.find_by!(name: "Captain Soranna")

    assert page.notables.exists?(entity: goblin)
    assert adventure.notables.exists?(entity: npc)
    assert_equal "Goblin", page.notables.find_by!(entity: goblin).name
  end

  test "admin stock compendium + campaign import links encounter combatants to stock creatures via notables" do
    import = import_for_multiple(
      { file: "sample_compendium.xml", kind: "compendium" },
      { file: "sample_campaign.xml", kind: "campaign" },
      mode: Importer::Preview::ADMIN_STOCK
    )

    assert_difference("Storybuilder::Notable.count", 2) do
      Importer::ProcessImportJob.perform_now(import.id)
    end

    page = Storybuilder::Page.find_by!(name: "Road Ambush")
    adventure = Storybuilder::StockAdventure.find_by!(name: "Elsir Vale")
    goblin = Entitybuilder::StockCreature.find_by!(name: "Goblin")
    npc = Entitybuilder::StockNpc.find_by!(name: "Captain Soranna")

    assert page.notables.exists?(entity: goblin)
    assert adventure.notables.exists?(entity: npc)
  end

  test "reimport does not create duplicate notables" do
    import = import_for_multiple(
      { file: "sample_compendium.xml", kind: "compendium" },
      { file: "sample_campaign.xml", kind: "campaign" },
      mode: Importer::Preview::RESIDENT_CONTENT
    )
    Importer::ProcessImportJob.perform_now(import.id)

    reimport = import_for_multiple(
      { file: "sample_compendium.xml", kind: "compendium" },
      { file: "sample_campaign.xml", kind: "campaign" },
      mode: Importer::Preview::RESIDENT_CONTENT
    )

    assert_no_difference("Storybuilder::Notable.count") do
      Importer::ProcessImportJob.perform_now(reimport.id)
    end
  end

  test "monster import creates ability scores, defense, trackable, movement, and attacks" do
    import = import_for("sample_compendium.xml", mode: Importer::Preview::RESIDENT_CONTENT)
    Importer::ProcessImportJob.perform_now(import.id)

    goblin = Entitybuilder::ResidentCreature.find_by!(name: "Goblin")
    assert_equal 6, goblin.ability_scores.count
    assert_equal 8, goblin.ability_scores.find_by!(name: "Strength").base
    assert_equal 14, goblin.ability_scores.find_by!(name: "Dexterity").base

    assert goblin.defenses.exists?(name: "Armor Class")
    assert_equal 15, goblin.defenses.find_by!(name: "Armor Class").base

    assert goblin.trackables.exists?(name: "Hit Points")
    assert_equal 7, goblin.trackables.find_by!(name: "Hit Points").maximum

    assert goblin.movements.exists?(name: "Speed")
    assert_equal 30, goblin.movements.find_by!(name: "Speed").base

    assert_equal 2, goblin.attacks.count
    scimitar = goblin.attacks.find_by!(name: "Scimitar")
    assert_equal "melee", scimitar.attack_type
    assert_equal 4, scimitar.attack_bonus
    assert_equal "1d6", scimitar.damage_dice
    assert_equal 2, scimitar.damage_bonus
    assert_equal "ranged", goblin.attacks.find_by!(name: "Shortbow").attack_type

    assert_equal "1/4", goblin.short_description
  end

  test "monster import creates creature type descriptor" do
    import = import_for("sample_compendium.xml", mode: Importer::Preview::RESIDENT_CONTENT)
    Importer::ProcessImportJob.perform_now(import.id)

    goblin = Entitybuilder::ResidentCreature.find_by!(name: "Goblin")
    assert goblin.descriptors.exists?(name: "Type")
    assert_equal "humanoid (goblinoid)", goblin.descriptors.find_by!(name: "Type").description
  end

  test "spell import creates record with full description from multiple text nodes" do
    import = import_for("sample_compendium.xml", mode: Importer::Preview::RESIDENT_CONTENT)
    Importer::ProcessImportJob.perform_now(import.id)

    spell = Rulebuilder::ResidentSpell.find_by!(name: "Fire Bolt")
    assert_equal "A ranged spell attack.\nDeals fire damage.", spell.full_description
  end

  test "standalone pc file import creates resident character with ability scores, saves, skills, and attack" do
    import = import_for_kind_with_file("sample_pc.xml", kind: "pc", mode: Importer::Preview::RESIDENT_CONTENT)

    assert_difference("Entitybuilder::ResidentCharacter.count", 1) do
      Importer::ProcessImportJob.perform_now(import.id)
    end

    assert_equal "succeeded", import.reload.status
    character = Entitybuilder::ResidentCharacter.find_by!(name: "Quinthya")
    assert_equal residents(:razune), character.resident
    assert_equal "Private", character.privacy

    assert_equal 6, character.ability_scores.count
    assert_equal 10, character.ability_scores.find_by!(name: "Strength").base
    assert_equal 16, character.ability_scores.find_by!(name: "Dexterity").base

    assert character.defenses.exists?(name: "Armor Class")
    assert_equal 15, character.defenses.find_by!(name: "Armor Class").base

    assert character.trackables.exists?(name: "Hit Points")
    assert_equal 14, character.trackables.find_by!(name: "Hit Points").maximum

    assert character.saving_throws.exists?(name: "Strength")
    assert_equal 2, character.saving_throws.find_by!(name: "Strength").base
    assert character.saving_throws.exists?(name: "Dexterity")

    assert character.skills.exists?(name: "Acrobatics")
    assert_equal 5, character.skills.find_by!(name: "Acrobatics").bonus

    assert character.attacks.exists?(name: "Unarmed Strike")
    unarmed = character.attacks.find_by!(name: "Unarmed Strike")
    assert_equal "melee", unarmed.attack_type
    assert_equal 5, unarmed.attack_bonus
  end

  test "characters file imports resident npcs counted during preview" do
    import = import_for_kind_with_file("sample_characters.xml", kind: "characters", mode: Importer::Preview::RESIDENT_CONTENT)

    assert_difference("Entitybuilder::ResidentNpc.count", 1) do
      Importer::ProcessImportJob.perform_now(import.id)
    end

    assert_equal "succeeded", import.reload.status
    npc = Entitybuilder::ResidentNpc.find_by!(name: "Captain Soranna")
    assert_equal residents(:razune), npc.resident
    assert_equal "Leader of the town guard.", npc.full_description
  end

  test "standalone pc file reimport replaces existing imported character" do
    Importer::ProcessImportJob.perform_now(
      import_for_kind_with_file("sample_pc.xml", kind: "pc", mode: Importer::Preview::RESIDENT_CONTENT).id
    )
    reimport = import_for_kind_with_file("sample_pc.xml", kind: "pc", mode: Importer::Preview::RESIDENT_CONTENT)

    assert_no_difference("Entitybuilder::ResidentCharacter.count") do
      Importer::ProcessImportJob.perform_now(reimport.id)
    end

    assert_equal "succeeded", reimport.reload.status
    assert_equal [ "replaced" ], reimport.import_results.distinct.pluck(:outcome)
  end

  test "pc file and campaign with same label merge into one character with both stats and backstory" do
    import = import_for_multiple(
      { file: "sample_pc.xml", kind: "pc" },
      { file: "sample_pc_campaign.xml", kind: "campaign" },
      mode: Importer::Preview::RESIDENT_CONTENT
    )

    assert_difference("Entitybuilder::ResidentCharacter.count", 1) do
      Importer::ProcessImportJob.perform_now(import.id)
    end

    character = Entitybuilder::ResidentCharacter.find_by!(name: "Quinthya")
    assert_equal 6, character.ability_scores.count
    assert_equal "A mysterious elven monk from the woods, seeking enlightenment.", character.full_description
  end

  test "admin stock mode skips standalone pc files" do
    import = import_for_kind_with_file("sample_pc.xml", kind: "pc", mode: Importer::Preview::ADMIN_STOCK)

    assert_no_difference("Entitybuilder::ResidentCharacter.count") do
      Importer::ProcessImportJob.perform_now(import.id)
    end

    assert_equal "partial", import.reload.status
    assert_equal "no stock character target", import.import_results.find_by!(entity_type: "pc").reason
  end

  private

  def import_for(file_name, mode:)
    preview = preview_for(mode)
    preview.add_uploads([ uploaded_file(file_name) ])
    Importer::Import.create!(resident: preview.resident, mode: preview.mode, source: preview.source,
                             status: Importer::Import::QUEUED, preview: preview)
  end

  def import_for_multiple(*file_specs, mode:)
    import = Importer::Import.create!(resident: resident_for(mode), mode: mode, source: Importer::Preview::GAME_MASTER_5_XML,
                                      status: Importer::Import::QUEUED)
    file_specs.each do |spec|
      File.open(importer_fixture_file(spec[:file])) do |file|
        import.import_files.create!(kind: spec[:kind], parse_status: "pending", file: file)
      end
    end
    import
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

  def import_for_kind_with_file(file_name, kind:, mode:)
    import = Importer::Import.create!(resident: resident_for(mode), mode: mode, source: Importer::Preview::GAME_MASTER_5_XML,
                                      status: Importer::Import::QUEUED)
    File.open(importer_fixture_file(file_name)) do |file|
      import.import_files.create!(kind: kind, parse_status: "pending", file: file)
    end
    import
  end

  def imported_provenance_notes(campaign)
    campaign.game_master_notes.select do |note|
      note.full_description.to_s.include?("Game Master 5 XML") &&
        note.full_description.to_s.include?("/imports/")
    end
  end
end
