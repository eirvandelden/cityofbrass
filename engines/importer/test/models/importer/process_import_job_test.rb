require_relative "../../test_helper"

class ImporterProcessImportJobTest < ActiveSupport::TestCase
  test "process import job uses the imports queue" do
    assert_equal "imports", Importer::ProcessImportJob.queue_name
  end

  test "compendium import gives blank-name entities unique placeholder names" do
    xml = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <compendium>
        <monster><name></name><ac>10</ac></monster>
        <monster><name></name><ac>11</ac></monster>
        <monster><name>Survivor</name><ac>12</ac></monster>
      </compendium>
    XML
    import = import_for_xml(xml, kind: "compendium")
    Importer::ProcessImportJob.perform_now(import.id)

    assert_equal "succeeded", import.reload.status
    assert Entitybuilder::ResidentCreature.exists?(name: "Survivor")
    no_names = Entitybuilder::ResidentCreature.where("name LIKE ?", "No Name%")
    assert_equal 2, no_names.count, "each blank-name entity should import as a distinct record, not merge"
    assert_not import.import_results.where(outcome: "failed").exists?
  end

  test "monster import preserves AC source and HP formula in parentheses" do
    xml = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <compendium>
        <monster>
          <name>Plated Beast</name>
          <ac>15 (natural armor)</ac>
          <hp>59 (7d10+21)</hp>
        </monster>
      </compendium>
    XML
    import = import_for_xml(xml, kind: "compendium")
    Importer::ProcessImportJob.perform_now(import.id)

    creature = Entitybuilder::ResidentCreature.find_by!(name: "Plated Beast")
    ac = creature.defenses.find_by!(name: "Armor Class")
    assert_equal 15, ac.base
    assert_equal "natural armor", ac.description
    hp = creature.trackables.find_by!(name: "Hit Points")
    assert_equal 59, hp.maximum
    assert_equal "7d10+21", hp.description
  end

  test "monster trait recharge and attack are preserved in the rule description" do
    xml = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <compendium>
        <monster>
          <name>Charger</name>
          <trait>
            <name>Rampage</name>
            <text>The beast charges.</text>
            <recharge>5-6</recharge>
            <attack>Gore|+7|2d6+4</attack>
          </trait>
        </monster>
      </compendium>
    XML
    import = import_for_xml(xml, kind: "compendium")
    Importer::ProcessImportJob.perform_now(import.id)

    rule = Rulebuilder::ResidentRule.find_by!(name: "Rampage")
    assert_includes rule.full_description, "The beast charges."
    assert_includes rule.full_description, "5-6"
    assert_includes rule.full_description, "Gore|+7|2d6+4"
  end

  test "monster import does not truncate long attack descriptions" do
    long_text = "Melee Weapon Attack. " + ("X" * 6_500)
    xml = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <compendium>
        <monster>
          <name>Verbose Brute</name>
          <action>
            <name>Slam</name>
            <text>#{long_text}</text>
            <attack>Slam|+5|2d8+3</attack>
          </action>
        </monster>
      </compendium>
    XML
    import = import_for_xml(xml, kind: "compendium")
    Importer::ProcessImportJob.perform_now(import.id)

    attack = Entitybuilder::ResidentCreature.find_by!(name: "Verbose Brute").attacks.find_by!(name: "Slam")
    assert_includes attack.description, long_text
  end

  test "monster import splits comma-separated skills and saves in one element" do
    xml = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <compendium>
        <monster>
          <name>Ezmerelda</name>
          <save>Dex +4, Con +5</save>
          <skill>Acrobatics +7, Arcana +6, Medicine +3</skill>
        </monster>
      </compendium>
    XML
    import = import_for_xml(xml, kind: "compendium")
    Importer::ProcessImportJob.perform_now(import.id)

    creature = Entitybuilder::ResidentCreature.find_by!(name: "Ezmerelda")
    assert_equal 5, creature.saving_throws.find_by!(name: "Con").base
    assert_equal 7, creature.skills.find_by!(name: "Acrobatics").base if creature.skills.column_names.include?("base")
    assert_equal 6, creature.skills.find_by!(name: "Arcana").bonus
    assert_equal 3, creature.skills.find_by!(name: "Medicine").bonus
  end

  test "item import includes rarity detail and value in description" do
    xml = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <compendium>
        <item>
          <name>Bloodseeker</name>
          <type>M</type>
          <detail>rare (requires attunement)</detail>
          <value>300</value>
          <text>A cruel blade.</text>
        </item>
      </compendium>
    XML
    import = import_for_xml(xml, kind: "compendium")
    Importer::ProcessImportJob.perform_now(import.id)

    item = Rulebuilder::ResidentItem.find_by!(name: "Bloodseeker")
    assert_includes item.full_description, "rare (requires attunement)"
    assert_includes item.full_description, "300"
  end

  test "class import includes armor, weapon, and tool proficiencies in description" do
    xml = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <compendium>
        <class>
          <name>Barbarian</name>
          <hd>12</hd>
          <armor>light armor, medium armor, shields</armor>
          <weapons>simple weapons, martial weapons</weapons>
          <tools>none</tools>
        </class>
      </compendium>
    XML
    import = import_for_xml(xml, kind: "compendium")
    Importer::ProcessImportJob.perform_now(import.id)

    rule = Rulebuilder::ResidentRule.find_by!(name: "Barbarian")
    assert_includes rule.full_description, "light armor, medium armor, shields"
    assert_includes rule.full_description, "simple weapons, martial weapons"
  end

  test "monster with a blank-name trait still imports the trait under a placeholder name" do
    xml = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <compendium>
        <monster>
          <name>Rahadin</name>
          <ac>16</ac>
          <trait><name>Deathly Choir</name><text>Whenever Rahadin deals damage...</text></trait>
          <trait><name></name><text>Magic Weapon, Nondetection</text></trait>
        </monster>
      </compendium>
    XML
    import = import_for_xml(xml, kind: "compendium")
    Importer::ProcessImportJob.perform_now(import.id)

    assert_equal "succeeded", import.reload.status
    creature = Entitybuilder::ResidentCreature.find_by!(name: "Rahadin")
    names = creature.linked_rules.map(&:name)
    assert_includes names, "Deathly Choir"
    assert_equal 2, names.size, "the blank-name trait should still be imported, under a placeholder name"
    placeholder = names.find { |n| n != "Deathly Choir" }
    assert_match(/\ANo Name/, placeholder)
    assert_equal "Magic Weapon, Nondetection",
                 Rulebuilder::ResidentRule.find_by!(name: placeholder).full_description
  end

  test "feat import stores prerequisite" do
    xml = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <compendium>
        <feat>
          <name>Grappler</name>
          <prerequisite>Strength 13 or higher</prerequisite>
          <text>You've developed the skills necessary to hold your own in close-quarters grappling.</text>
        </feat>
      </compendium>
    XML
    import = import_for_xml(xml, kind: "compendium")
    Importer::ProcessImportJob.perform_now(import.id)

    feat = Rulebuilder::ResidentRule.find_by!(name: "Grappler")
    assert_equal "Strength 13 or higher", feat.prerequisites
  end

  test "campaign import dedupes encounter pages that share a slug" do
    xml = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <campaign>
        <name>Slug Test Campaign</name>
        <adventure>
          <name>Slug Vale</name>
          <encounter><name>1. Main Gate</name><text>The gate.</text></encounter>
          <encounter><name>------\n\n1. MAIN GATE</name><text>Same gate, junk prefix.</text></encounter>
        </adventure>
      </campaign>
    XML
    import = import_for_xml(xml, kind: "campaign")
    Importer::ProcessImportJob.perform_now(import.id)

    assert_equal "succeeded", import.reload.status
    adventure = Storybuilder::ResidentAdventure.find_by!(name: "Slug Vale")
    assert_equal 1, adventure.pages.count
  end

  test "compendium import preserves over-long descriptions without truncating" do
    long_text = "A" * 13_000
    xml = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <compendium>
        <item><name>Verbose Tome</name><type>G</type><text>#{long_text}</text></item>
      </compendium>
    XML
    import = import_for_xml(xml, kind: "compendium")
    Importer::ProcessImportJob.perform_now(import.id)

    assert_equal "succeeded", import.reload.status
    item = Rulebuilder::ResidentItem.find_by!(name: "Verbose Tome")
    assert_includes item.full_description, long_text
  end

  test "item import decodes type codes into categories and maps containers" do
    xml = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <compendium>
        <item><name>Longsword</name><type>M</type></item>
        <item><name>Plate</name><type>HA</type></item>
        <item><name>Wand of Wonder</name><type>W</type></item>
        <item><name>Potion of Healing</name><type>P</type></item>
        <item><name>Rope</name><type>G</type></item>
        <container><name>Backpack</name></container>
      </compendium>
    XML
    import = import_for_xml(xml, kind: "compendium")
    Importer::ProcessImportJob.perform_now(import.id)

    assert_equal "weapon", Rulebuilder::ResidentItem.find_by!(name: "Longsword").category
    assert_equal "armor", Rulebuilder::ResidentItem.find_by!(name: "Plate").category
    assert_equal "wondrous", Rulebuilder::ResidentItem.find_by!(name: "Wand of Wonder").category
    assert_equal "potion", Rulebuilder::ResidentItem.find_by!(name: "Potion of Healing").category
    assert_equal "gear", Rulebuilder::ResidentItem.find_by!(name: "Rope").category
    assert_equal "container", Rulebuilder::ResidentItem.find_by!(name: "Backpack").category
  end

  test "spell import decodes school, levels, components, ritual tag, and timing" do
    xml = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <compendium>
        <spell>
          <name>Fireball</name>
          <level>3</level><school>EV</school><ritual>YES</ritual>
          <time>1 action</time><range>150 feet</range><duration>Instantaneous</duration>
          <classes>Wizard, Sorcerer</classes>
          <components>V, S, M (a tiny ball of bat guano and sulfur)</components>
        </spell>
      </compendium>
    XML
    import = import_for_xml(xml, kind: "compendium")
    Importer::ProcessImportJob.perform_now(import.id)

    spell = Rulebuilder::ResidentSpell.find_by!(name: "Fireball")
    assert_equal "Evocation", spell.school
    assert_equal [ "Wizard 3", "Sorcerer 3" ], spell.levels
    assert_equal "V, S, M (a tiny ball of bat guano and sulfur)", spell.components
    assert_equal "1 action", spell.casting_time
    assert_equal "150 feet", spell.range
    assert_equal "Instantaneous", spell.duration
    assert_includes spell.tags, "ritual"
  end

  test "spell import stores over-long components without failing" do
    materials = "a diamond worth at least 1,000 gp and a vessel worth at least 2,000 gp " + ("x" * 300)
    xml = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <compendium>
        <spell><name>Clone</name><level>8</level><school>N</school><components>V, S, M (#{materials})</components></spell>
      </compendium>
    XML
    import = import_for_xml(xml, kind: "compendium")
    Importer::ProcessImportJob.perform_now(import.id)

    assert_equal "succeeded", import.reload.status
    spell = Rulebuilder::ResidentSpell.find_by!(name: "Clone")
    assert_includes spell.components, materials
  end

  test "spell import assembles components from v/s/m sub-elements when present" do
    xml = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <compendium>
        <spell>
          <name>Mage Hand</name>
          <level>0</level>
          <school>T</school>
          <components><v/><s/></components>
        </spell>
      </compendium>
    XML
    import = import_for_xml(xml, kind: "compendium")
    Importer::ProcessImportJob.perform_now(import.id)

    assert_equal "V, S", Rulebuilder::ResidentSpell.find_by!(name: "Mage Hand").components
  end

  test "race import creates a Species rule with ability and proficiency text" do
    xml = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <compendium>
        <race>
          <name>Wood Elf</name>
          <ability>Dex 2, Wis 1</ability>
          <proficiency>Perception</proficiency>
          <trait><name>Darkvision</name><text>60 ft.</text></trait>
        </race>
      </compendium>
    XML
    import = import_for_xml(xml, kind: "compendium")
    Importer::ProcessImportJob.perform_now(import.id)

    rule = Rulebuilder::ResidentRule.find_by!(name: "Wood Elf")
    assert_equal "Species", rule.rule_type
    assert_includes rule.full_description, "Dex 2, Wis 1"
    assert_includes rule.full_description, "Perception"
    assert_includes rule.full_description, "Darkvision"
  end

  test "background import creates a Backgrounds rule" do
    xml = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <compendium>
        <background>
          <name>Acolyte</name>
          <proficiency>Insight, Religion</proficiency>
        </background>
      </compendium>
    XML
    import = import_for_xml(xml, kind: "compendium")
    Importer::ProcessImportJob.perform_now(import.id)

    rule = Rulebuilder::ResidentRule.find_by!(name: "Acolyte")
    assert_equal "Backgrounds", rule.rule_type
    assert_includes rule.full_description, "Insight, Religion"
  end

  test "monster spellcasting imports ability descriptor, slot trackables, and spell list" do
    xml = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <compendium>
        <monster>
          <name>Archmage</name>
          <spellAbility>Intelligence</spellAbility>
          <slots>4,3,3,2</slots>
          <spells>Fire Bolt, Fireball</spells>
        </monster>
      </compendium>
    XML
    import = import_for_xml(xml, kind: "compendium")
    Importer::ProcessImportJob.perform_now(import.id)

    creature = Entitybuilder::ResidentCreature.find_by!(name: "Archmage")
    assert_equal "Intelligence", creature.descriptors.find_by!(name: "Spellcasting Ability").description
    assert_equal 4, creature.trackables.find_by!(name: "Cantrips").maximum
    assert_equal 3, creature.trackables.find_by!(name: "Spell Slots (1st)").maximum
    assert_equal 2, creature.trackables.find_by!(name: "Spell Slots (3rd)").maximum
    assert_equal "Fire Bolt, Fireball", creature.descriptors.find_by!(name: "Spells").description
  end

  test "pc equipped armor falls back to a descriptor when the item is unknown" do
    xml = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <pc version="5">
        <label>Armored</label>
        <name>Human Fighter 1</name>
        <armor>Plate Armor</armor>
      </pc>
    XML
    import = import_for_xml(xml, kind: "pc")
    Importer::ProcessImportJob.perform_now(import.id)

    character = Entitybuilder::ResidentCharacter.find_by!(name: "Armored")
    assert_equal "Plate Armor", character.descriptors.find_by!(name: "Equipped Armor").description
  end

  test "pc equipped armor links to an inventory item when the item was imported" do
    compendium = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <compendium><item><name>Plate Armor</name><type>HA</type></item></compendium>
    XML
    pc = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <pc version="5"><label>Knight</label><name>Human Fighter 1</name><armor>Plate Armor</armor></pc>
    XML
    import = import_for_inline_files([ { xml: compendium, kind: "compendium" }, { xml: pc, kind: "pc" } ])
    Importer::ProcessImportJob.perform_now(import.id)

    character = Entitybuilder::ResidentCharacter.find_by!(name: "Knight")
    item = Rulebuilder::ResidentItem.find_by!(name: "Plate Armor")
    inventory = character.inventory_items.find_by!(item: item)
    assert inventory.equipped
    assert_not character.descriptors.exists?(name: "Equipped Armor")
  end

  test "pc import creates hit dice and spell slot trackables" do
    xml = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <pc version="5">
        <label>Caster</label>
        <name>Gnome Wizard 3</name>
        <hp>20 (3d6)</hp>
        <class><hd>d6</hd><hdCurrent>2</hdCurrent><slots>4,3,2</slots></class>
      </pc>
    XML
    import = import_for_xml(xml, kind: "pc")
    Importer::ProcessImportJob.perform_now(import.id)

    character = Entitybuilder::ResidentCharacter.find_by!(name: "Caster")
    hit_dice = character.trackables.find_by!(name: "Hit Dice (d6)")
    assert_equal 3, hit_dice.maximum
    assert_equal 2, hit_dice.current
    assert_equal 4, character.trackables.find_by!(name: "Cantrips").maximum
    assert_equal 3, character.trackables.find_by!(name: "Spell Slots (1st)").maximum
  end

  test "empty compendium succeeds and imports nothing" do
    xml = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <compendium></compendium>
    XML
    import = import_for_xml(xml, kind: "compendium")
    Importer::ProcessImportJob.perform_now(import.id)

    assert_equal "succeeded", import.reload.status
    assert_equal 0, import.import_results.count
  end

  test "admin stock compendium import creates stock records and results" do
    import = import_for("sample_compendium.xml", mode: Importer::Preview::ADMIN_STOCK)

    assert_difference("Entitybuilder::StockCreature.count", 2) do
      assert_difference("Rulebuilder::StockItem.count", 1) do
        assert_difference("Rulebuilder::StockSpell.count", 1) do
          assert_difference("Rulebuilder::StockRule.count", 6) do
            Importer::ProcessImportJob.perform_now(import.id)
          end
        end
      end
    end

    assert_equal "succeeded", import.reload.status
    assert_equal 10, import.import_results.created.count
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
          assert_difference("Rulebuilder::ResidentRule.count", 6) do
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
      assert_difference("Storybuilder::ResidentAdventure.count", 2) do
        assert_difference("Storybuilder::Page.count", 2) do
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
    assert_equal "Session One", Storybuilder::Page.find_by!(name: "Session One").name
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
    assert_equal [ "This is adventure content, not a private GM note.", "This is a second text block." ],
                 Storybuilder::Page.find_by!(name: "0. Introduction").sections.order(:sort_order).pluck(:content)
    assert_equal [ "0. Introduction", "Upper Floor 1. Keep Out!" ], adventure.menu_items.order(:sort_order).pluck(:item_label)
    assert_equal [ "Page Only Campaign" ], campaign.menu_items.order(:sort_order).pluck(:item_label)
  end

  test "resident campaign import fills campaign menu with adventures and loose pages in xml order" do
    import = import_for("campaign_menu_order.xml", mode: Importer::Preview::RESIDENT_CONTENT)

    assert_difference("Campaignmanager::Campaign.count", 1) do
      assert_difference("Storybuilder::ResidentAdventure.count", 3) do
        assert_difference("Storybuilder::Page.count", 4) do
          Importer::ProcessImportJob.perform_now(import.id)
        end
      end
    end

    campaign = Campaignmanager::Campaign.find_by!(name: "Menu Campaign")
    loose_note = Storybuilder::Page.find_by!(name: "Loose Note")

    assert_equal "succeeded", import.reload.status
    assert_equal [ "First Adventure", "Second Adventure", "Menu Campaign" ],
                 campaign.menu_items.order(:sort_order).pluck(:item_label)
    assert_equal [ "Loose note opening.", "Loose note follow-up." ],
                 loose_note.sections.order(:sort_order).pluck(:content)
  end

  test "resident campaign import preserves intermezzo order between adventures" do
    import = import_for("campaign_menu_intermezzo.xml", mode: Importer::Preview::RESIDENT_CONTENT)

    assert_difference("Campaignmanager::Campaign.count", 1) do
      assert_difference("Storybuilder::ResidentAdventure.count", 3) do
        assert_difference("Storybuilder::Page.count", 3) do
          Importer::ProcessImportJob.perform_now(import.id)
        end
      end
    end

    campaign = Campaignmanager::Campaign.find_by!(name: "Intermezzo Campaign")

    assert_equal "succeeded", import.reload.status
    assert_equal [ "First Adventure", "Intermezzo Campaign", "Second Adventure" ],
                 campaign.menu_items.order(:sort_order).pluck(:item_label)
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

    assert_equal 7, notes.count
    notes.each do |note|
      assert_includes note.full_description, "Game Master 5 XML"
      assert_includes note.full_description, "/imports/#{import.id}"
      assert_match(/\d{4}-\d{2}-\d{2}/, note.full_description)
    end

    npc = Entitybuilder::ResidentNpc.find_by!(name: "Captain Soranna")
    npc_note = notes.find { |note| note.full_description.include?("Captain Soranna") }

    assert npc_note.notables.exists?(entity: npc)
  end

  test "resident campaign import links created adventure creatures to adventure notables" do
    import = import_for("sample_campaign_with_embedded_content.xml", mode: Importer::Preview::RESIDENT_CONTENT)

    assert_difference("Storybuilder::Notable.count", 3) do
      Importer::ProcessImportJob.perform_now(import.id)
    end

    adventure = Storybuilder::ResidentAdventure.find_by!(name: "Shade Vault")
    campaign = Campaignmanager::Campaign.find_by!(name: "Inheritance")
    creature = Entitybuilder::ResidentCreature.find_by!(name: "Brute CR1")

    assert adventure.notables.exists?(entity: creature)
    assert_not campaign.notables.exists?(entity: creature)
  end

  test "resident campaign import links campaign npcs to campaign notables" do
    import = import_for("sample_campaign.xml", mode: Importer::Preview::RESIDENT_CONTENT)

    assert_difference("Campaignmanager::Notable.where(notableable_type: 'Campaignmanager::Campaign').count", 1) do
      Importer::ProcessImportJob.perform_now(import.id)
    end

    campaign = Campaignmanager::Campaign.find_by!(name: "Red Hand")
    npc = Entitybuilder::ResidentNpc.find_by!(name: "Captain Soranna")

    assert campaign.notables.exists?(entity: npc)
    assert Storybuilder::ResidentAdventure.find_by!(name: "Elsir Vale").notables.where(entity: npc).none?
  end

  test "file failure does not leave later files pending" do
    import = import_for_multiple(
      { file: "malformed.xml", kind: "compendium" },
      { file: "sample_campaign.xml", kind: "campaign" },
      mode: Importer::Preview::RESIDENT_CONTENT
    )

    assert_difference("Campaignmanager::Campaign.count", 1) do
      Importer::ProcessImportJob.perform_now(import.id)
    end

    assert_equal "partial", import.reload.status
    assert_equal %w[failed parsed], import.import_files.order(:created_at).pluck(:parse_status)
    assert import.import_results.failed.exists?(entity_type: "compendium", entity_name: "malformed.xml")
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

  test "admin stock campaign import creates note page sections from text blocks" do
    import = import_for_kind_with_file("campaign_level_pages.xml", kind: "campaign",
                                                                   mode: Importer::Preview::ADMIN_STOCK)

    assert_difference("Storybuilder::StockAdventure.count", 1) do
      assert_difference("Storybuilder::Page.count", 2) do
        Importer::ProcessImportJob.perform_now(import.id)
      end
    end

    assert_equal "succeeded", import.reload.status
    assert_equal [ "This is adventure content, not a private GM note.", "This is a second text block." ],
                 Storybuilder::Page.find_by!(name: "0. Introduction").sections.order(:sort_order).pluck(:content)
  end

  test "campaign note with title element creates sections from text blocks" do
    import = import_for_kind_with_file("campaign_notes_with_title.xml", kind: "campaign",
                                                                        mode: Importer::Preview::ADMIN_STOCK)

    Importer::ProcessImportJob.perform_now(import.id)

    assert_equal "succeeded", import.reload.status
    page = Storybuilder::Page.find_by!(name: "0. Introduction")
    assert_nil page.full_description
    assert_equal 2, page.sections.count
    assert_equal [ "This is the first paragraph of the note.",
                   "This is the second paragraph." ],
                 page.sections.order(:sort_order).pluck(:content)
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
    assert_equal [ "Road Ambush" ], Storybuilder::ResidentAdventure.find_by!(name: "Elsir Vale").menu_items.pluck(:item_label)
    assert_equal [ "Forest Shrine" ], Storybuilder::ResidentAdventure.find_by!(name: "Witchwood").menu_items.pluck(:item_label)
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
    assert_equal %w[adventure adventure campaign encounter note npc pc],
                 import.import_results.replaced.order(:entity_type).pluck(:entity_type)
    assert_equal [ "Road Ambush" ], Storybuilder::ResidentAdventure.find_by!(name: "Elsir Vale").menu_items.pluck(:item_label)
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
    assert_equal 10, import.import_results.replaced.count
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
    campaign = Campaignmanager::Campaign.find_by!(name: "Red Hand")
    goblin = Entitybuilder::ResidentCreature.find_by!(name: "Goblin")
    npc = Entitybuilder::ResidentNpc.find_by!(name: "Captain Soranna")

    assert page.notables.exists?(entity: goblin)
    assert adventure.notables.exists?(entity: goblin)
    assert campaign.notables.exists?(entity: npc)
    assert_not adventure.notables.exists?(entity: npc)
    assert_equal "Goblin", page.notables.find_by!(entity: goblin).name
  end

  test "admin stock compendium + campaign import links encounter combatants to stock creatures via notables" do
    import = import_for_multiple(
      { file: "sample_compendium.xml", kind: "compendium" },
      { file: "sample_campaign.xml", kind: "campaign" },
      mode: Importer::Preview::ADMIN_STOCK
    )

    assert_difference("Storybuilder::Notable.count", 1) do
      Importer::ProcessImportJob.perform_now(import.id)
    end

    page = Storybuilder::Page.find_by!(name: "Road Ambush")
    adventure = Storybuilder::StockAdventure.find_by!(name: "Elsir Vale")
    goblin = Entitybuilder::StockCreature.find_by!(name: "Goblin")
    npc = Entitybuilder::StockNpc.find_by!(name: "Captain Soranna")

    assert page.notables.exists?(entity: goblin)
    assert_not adventure.notables.exists?(entity: npc)
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

  test "monster import creates saving throws and skills" do
    import = import_for("sample_compendium.xml", mode: Importer::Preview::RESIDENT_CONTENT)
    Importer::ProcessImportJob.perform_now(import.id)

    goblin = Entitybuilder::ResidentCreature.find_by!(name: "Goblin")
    assert goblin.saving_throws.exists?(name: "Dex")
    assert_equal 4, goblin.saving_throws.find_by!(name: "Dex").base
    assert goblin.skills.exists?(name: "Stealth")
    assert_equal 6, goblin.skills.find_by!(name: "Stealth").bonus
  end

  test "monster import stores description and per-mode speeds" do
    import = import_for_kind_with_file("sample_monster_rich.xml", kind: "compendium",
                                       mode: Importer::Preview::RESIDENT_CONTENT)
    Importer::ProcessImportJob.perform_now(import.id)

    creature = Entitybuilder::ResidentCreature.find_by!(name: "Arcuballis")
    assert_equal "A magical beast resembling a griffon crossed with a triceratops.", creature.full_description
    assert_equal 30, creature.movements.find_by!(name: "Speed").base
    assert_equal 60, creature.movements.find_by!(name: "Fly Speed").base
    assert_equal 20, creature.movements.find_by!(name: "Swim Speed").base
  end

  test "standalone pc import stores languages, senses, and race descriptors" do
    import = import_for_kind_with_file("sample_pc.xml", kind: "pc", mode: Importer::Preview::RESIDENT_CONTENT)
    Importer::ProcessImportJob.perform_now(import.id)

    character = Entitybuilder::ResidentCharacter.find_by!(name: "Quinthya")
    assert_equal "Common, Elvish", character.descriptors.find_by!(name: "Languages").description
    assert_equal "passive Perception 14", character.descriptors.find_by!(name: "Senses").description
    assert_equal "Elf (Wood)", character.descriptors.find_by!(name: "Race").description
  end

  test "gm5 nested character pc import creates character with abilities, class level, and hp" do
    import = import_for_kind_with_file("sample_pc_gm5.xml", kind: "pc", mode: Importer::Preview::RESIDENT_CONTENT)

    assert_difference("Entitybuilder::ResidentCharacter.count", 1) do
      Importer::ProcessImportJob.perform_now(import.id)
    end

    assert_equal "succeeded", import.reload.status
    character = Entitybuilder::ResidentCharacter.find_by!(name: "Human Rogue")
    assert_equal 6, character.ability_scores.count
    assert_equal 10, character.ability_scores.find_by!(name: "Strength").base
    assert_equal 15, character.ability_scores.find_by!(name: "Dexterity").base
    assert_equal 24, character.trackables.find_by!(name: "Hit Points").maximum
    assert_equal "Human", character.descriptors.find_by!(name: "Race").description

    class_level = character.class_levels.find_by!(name: "Rogue")
    assert_equal 3, class_level.level
  end

  test "monster import creates trait rules linked to the creature" do
    import = import_for("sample_compendium.xml", mode: Importer::Preview::RESIDENT_CONTENT)
    Importer::ProcessImportJob.perform_now(import.id)

    goblin = Entitybuilder::ResidentCreature.find_by!(name: "Goblin")
    assert_nil goblin.full_description

    trait = Rulebuilder::ResidentRule.find_by!(name: "Nimble Escape")
    assert_equal "Ability", trait.rule_type
    assert_equal "The goblin can take the Disengage or Hide action as a bonus action on each of its turns.",
                 trait.full_description
    assert_equal [ "Nimble Escape" ], goblin.linked_rules.map(&:name)
  end

  test "monster import creates creature type descriptor" do
    import = import_for("sample_compendium.xml", mode: Importer::Preview::RESIDENT_CONTENT)
    Importer::ProcessImportJob.perform_now(import.id)

    goblin = Entitybuilder::ResidentCreature.find_by!(name: "Goblin")
    assert goblin.descriptors.exists?(name: "Type")
    assert_equal "humanoid (goblinoid)", goblin.descriptors.find_by!(name: "Type").description
    assert_equal "Small", goblin.descriptors.find_by!(name: "Size").description
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

  test "npc import stores descriptors, defense, trackable, and description" do
    xml = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <characters version="5">
        <npc>
          <name>Captain Soranna</name>
          <size>M</size>
          <type>humanoid</type>
          <alignment>lawful good</alignment>
          <ac>18</ac>
          <hp>52</hp>
          <description>Leader of the town guard.</description>
        </npc>
      </characters>
    XML
    import = import_for_xml(xml, kind: "characters")
    Importer::ProcessImportJob.perform_now(import.id)

    npc = Entitybuilder::ResidentNpc.find_by!(name: "Captain Soranna")
    assert_equal "Leader of the town guard.", npc.full_description
    assert_equal "M", npc.descriptors.find_by!(name: "Size").description
    assert_equal "humanoid", npc.descriptors.find_by!(name: "Type").description
    assert_equal "lawful good", npc.descriptors.find_by!(name: "Alignment").description
    assert_equal 18, npc.defenses.find_by!(name: "Armor Class").base
    assert_equal 52, npc.trackables.find_by!(name: "Hit Points").maximum
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

  def import_for_xml(xml, kind:, mode: Importer::Preview::RESIDENT_CONTENT)
    import_for_inline_files([ { xml: xml, kind: kind } ], mode: mode)
  end

  def import_for_inline_files(specs, mode: Importer::Preview::RESIDENT_CONTENT)
    import = Importer::Import.create!(resident: resident_for(mode), mode: mode, source: Importer::Preview::GAME_MASTER_5_XML,
                                      status: Importer::Import::QUEUED)
    specs.each do |spec|
      Tempfile.create([ "inline", ".xml" ]) do |tmp|
        tmp.write(spec[:xml])
        tmp.flush
        File.open(tmp.path) do |file|
          import.import_files.create!(kind: spec[:kind], parse_status: "pending", file: file)
        end
      end
    end
    import
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
