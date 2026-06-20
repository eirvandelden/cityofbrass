require_relative "../../../../test_helper"

class ImporterGameMaster5XmlDocumentTest < ActiveSupport::TestCase
  test "monster record extracts all stat fields" do
    document = Importer::Sources::GameMaster5Xml::Document.new(importer_fixture_file("sample_compendium.xml"))

    assert_monster_record document.compendium_records.find { |record| record[:name] == "Goblin" }
  end

  test "compendium records include subclasses" do
    document = Importer::Sources::GameMaster5Xml::Document.new(importer_fixture_file("sample_compendium.xml"))
    subclass = document.compendium_records.find { |record| record[:name] == "Champion" }

    assert subclass
    assert_equal "subclass", subclass[:type]
    assert_equal "Fighter", subclass[:baseclass]
  end

  test "compendium records include bare class elements" do
    xml = <<~XML
      <compendium>
        <class>
          <name>Scout</name>
          <hd>10</hd>
          <proficiency>Stealth, Survival</proficiency>
          <numSkills>3</numSkills>
        </class>
      </compendium>
    XML

    document_for(xml) do |doc|
      klass = doc.compendium_records.find { |record| record[:type] == "class" }
      assert klass, "expected a class record from a <class> element"
      assert_equal "Scout", klass[:name]
      assert_equal "10", klass[:hd]
    end
  end

  test "compendium records include item templates as items" do
    xml = <<~XML
      <compendium>
        <itemtemplate>
          <name>Silvered %name%</name>
          <type>M</type>
          <magic>NO</magic>
          <text>Silvered ammunition or weapon.</text>
        </itemtemplate>
      </compendium>
    XML

    document_for(xml) do |doc|
      item = doc.compendium_records.find { |record| record[:name] == "Silvered %name%" }
      assert item, "expected an item record from an <itemtemplate> element"
      assert_equal "item", item[:type]
      assert_equal "M", item[:item_type]
      assert_equal [ "Silvered ammunition or weapon." ], item[:text]
    end
  end

  test "monster record extracts description text" do
    xml = <<~XML
      <compendium>
        <monster>
          <name>Hug Hug</name>
          <description>The lone surviving goblin cowers under the mine cart.</description>
        </monster>
      </compendium>
    XML

    document_for(xml) do |doc|
      monster = doc.compendium_records.find { |record| record[:type] == "monster" }
      assert_equal "The lone surviving goblin cowers under the mine cart.", monster[:description]
    end
  end

  test "character record reads gm5 nested character wrapper" do
    xml = <<~XML
      <pc version="5">
        <character>
          <name>Human Rogue</name>
          <abilities>10,15,12,13,8,14,</abilities>
          <race><name>Human</name></race>
          <class><name>Rogue</name><level>3</level></class>
          <hpMax>9</hpMax>
        </character>
      </pc>
    XML

    document_for(xml) do |doc|
      pc = doc.character_records.find { |record| record[:type] == "pc" }
      assert pc, "expected a pc record from a <character> wrapper"
      assert_equal "Human Rogue", pc[:name]
      assert_equal [ "10", "15", "12", "13", "8", "14" ], pc.values_at(:str, :dex, :con, :int, :wis, :cha)
      assert_equal "Human", pc[:race_name]
      assert_equal "Rogue", pc[:class_name]
      assert_equal "3", pc[:class_level]
      assert_equal "9", pc[:hp]
    end
  end

  test "encounter record extracts description from nested note text" do
    xml = <<~XML
      <campaign>
        <name>Test</name>
        <adventure>
          <name>Vale</name>
          <encounter>
            <name>Council Meeting</name>
            <note><name>Description</name><text>Lord Jarmaath: ruling lord</text></note>
          </encounter>
        </adventure>
      </campaign>
    XML

    document_for(xml) do |doc|
      encounter = doc.campaign_record[:adventures].first[:encounters].first
      assert_equal "Council Meeting", encounter[:name]
      assert_equal "Lord Jarmaath: ruling lord", encounter[:description]
    end
  end

  test "encounter record extracts description from both direct text and note text" do
    xml = <<~XML
      <campaign>
        <name>Test</name>
        <adventure>
          <name>Vale</name>
          <encounter>
            <name>Hybrid</name>
            <text>Direct text</text>
            <note><name>Description</name><text>Note text</text></note>
          </encounter>
        </adventure>
      </campaign>
    XML

    document_for(xml) do |doc|
      encounter = doc.campaign_record[:adventures].first[:encounters].first
      assert_equal "Direct text\nNote text", encounter[:description]
    end
  end

  test "encounter record extracts description from deeply nested note text" do
    xml = <<~XML
      <campaign>
        <name>Test</name>
        <adventure>
          <name>Vale</name>
          <encounter>
            <name>Ghost Lord</name>
            <note>
              <name>Outer Note</name>
              <note><name>Inner Note</name><text>The ghost lord text.</text></note>
            </note>
          </encounter>
        </adventure>
      </campaign>
    XML

    document_for(xml) do |doc|
      encounter = doc.campaign_record[:adventures].first[:encounters].first
      assert_equal "The ghost lord text.", encounter[:description]
    end
  end

  test "action nodes extract attack notation from structured attack sub-elements" do
    xml = <<~XML
      <campaign>
        <name>Test</name>
        <monster>
          <name>Ettin</name>
          <action>
            <name>Battleaxe</name>
            <text>Melee Weapon Attack: +7 to hit.</text>
            <attack><name>Battleaxe</name><atk>7</atk><dmg>2d8+5</dmg></attack>
          </action>
        </monster>
      </campaign>
    XML

    document_for(xml) do |doc|
      monster = doc.compendium_records.find { |r| r[:name] == "Ettin" }
      assert_equal "Battleaxe|+7|2d8+5", monster[:actions].first[:attack]
    end
  end

  test "action nodes extract attack notation from direct atk and dmg elements" do
    xml = <<~XML
      <campaign>
        <name>Test</name>
        <monster>
          <name>Ghoul</name>
          <action>
            <name>Claw</name>
            <text>Melee Weapon Attack: +4 to hit.</text>
            <atk>4</atk>
            <dmg>2d4+2</dmg>
          </action>
        </monster>
      </campaign>
    XML

    document_for(xml) do |doc|
      monster = doc.compendium_records.find { |r| r[:name] == "Ghoul" }
      assert_equal "Claw|+4|2d4+2", monster[:actions].first[:attack]
    end
  end

  test "action nodes extract attack notation from direct dmg only element" do
    xml = <<~XML
      <campaign>
        <name>Test</name>
        <monster>
          <name>Trap</name>
          <action>
            <name>Spike</name>
            <text>Deals damage on trigger.</text>
            <dmg>1d8</dmg>
          </action>
        </monster>
      </campaign>
    XML

    document_for(xml) do |doc|
      monster = doc.compendium_records.find { |r| r[:name] == "Trap" }
      assert_equal "Spike|+|1d8", monster[:actions].first[:attack]
    end
  end

  test "reaction nodes extract attack notation" do
    xml = <<~XML
      <campaign>
        <name>Test</name>
        <monster>
          <name>Guard</name>
          <reaction>
            <name>Parry</name>
            <text>Melee attack.</text>
            <atk>3</atk>
            <dmg>1d6+1</dmg>
          </reaction>
        </monster>
      </campaign>
    XML

    document_for(xml) do |doc|
      monster = doc.compendium_records.find { |r| r[:name] == "Guard" }
      assert_equal "Parry|+3|1d6+1", monster[:reactions].first[:attack]
    end
  end

  test "encounter record extracts combatants" do
    xml = <<~XML
      <campaign>
        <name>Test</name>
        <adventure>
          <name>Vale</name>
          <encounter>
            <name>Road Ambush</name>
            <text>Ambush text</text>
            <combatant><monster>Goblin</monster></combatant>
            <combatant><monster>Goblin</monster></combatant>
            <combatant><monster>Orc</monster></combatant>
          </encounter>
        </adventure>
      </campaign>
    XML

    document_for(xml) do |doc|
      campaign = doc.campaign_record
      encounter = campaign[:adventures].first[:encounters].first
      assert_equal "Road Ambush", encounter[:name]
      assert_equal "Ambush text", encounter[:description]
      assert_equal 3, encounter[:combatants].size
      assert_equal [ "Goblin", "Goblin", "Orc" ], encounter[:combatants].map { |c| c[:name] }
    end
  end

  test "campaign record extracts embedded items and combatant monsters" do
    document = Importer::Sources::GameMaster5Xml::Document.new(importer_fixture_file("sample_campaign_with_embedded_content.xml"))
    campaign = document.campaign_record
    encounter = campaign[:adventures].first[:encounters].first

    assert_equal 2, campaign[:adventures].first[:encounters].size
    assert_equal [ "Brute CR1" ], encounter[:combatants].map { |combatant| combatant[:name] }
    assert_equal [ "Brute CR1" ], campaign[:monsters].map { |monster| monster[:name] }
    assert_equal [ "Symbol Of Life" ], campaign[:items].map { |item| item[:name] }
    assert_equal "28", campaign[:monsters].first[:hp]
    assert_equal "10", campaign[:monsters].first[:str]
    assert_equal "12", campaign[:monsters].first[:dex]
  end

  test "character_records parses standalone PC file" do
    document = Importer::Sources::GameMaster5Xml::Document.new(importer_fixture_file("sample_pc.xml"))

    assert_pc_record only_record(document.character_records)
  end

  test "document parsing closes the source file" do
    path = importer_fixture_file("sample_compendium.xml").to_s
    open_files_before = open_files_for(path)

    GC.disable
    3.times { Importer::Sources::GameMaster5Xml::Document.new(path).compendium_records }

    assert_equal open_files_before, open_files_for(path)
  ensure
    GC.enable
  end

  test "note record joins all text nodes as description" do
    xml = <<~XML
      <campaign>
        <name>Test</name>
        <note>
          <name>Session 1</name>
          <text>The party arrived at the inn.</text>
          <text>They met a stranger.</text>
        </note>
      </campaign>
    XML

    document_for(xml) do |doc|
      notes = doc.campaign_record[:notes]
      assert_equal 1, notes.size
      assert_equal "The party arrived at the inn.\nThey met a stranger.", notes.first[:description]
    end
  end

  private

  def assert_monster_record(monster)
    assert_equal "monster", monster[:type]
    assert_equal "Goblin", monster[:name]
    assert_equal "humanoid (goblinoid)", monster[:creature_type]
    assert_equal [ "S", "15 (leather armor, shield)", "7 (2d6)", "8", "14", "1/4", "poison" ],
                 monster.values_at(:size, :ac, :hp, :str, :dex, :cr, :immune)
    assert_equal [ "Dex +4" ], monster[:saves]
    assert_equal [ "Stealth +6" ], monster[:skills]
    assert_equal "Nimble Escape", only_record(monster[:traits])[:name]
    assert_equal "Scimitar|+4|1d6+2", monster[:actions].first[:attack]
  end

  def assert_pc_record(pc)
    assert_equal "pc", pc[:type]
    assert_equal "Quinthya", pc[:label]
    assert_equal "Elf (Wood) Monk 2", pc[:name]
    assert_equal [ "M", "15", "14 (2d8)", "10", "16" ], pc.values_at(:size, :ac, :hp, :str, :dex)
    assert_equal [ "Strength +2", "Dexterity +5" ], pc[:saves]
    assert_equal [ "Acrobatics +5", "Perception +4" ], pc[:skills]
    assert_equal "Unarmed Strike|+5|1d4+3", only_record(pc[:actions])[:attack]
  end

  def only_record(records)
    assert_equal 1, records.size
    records.first
  end

  def document_for(xml)
    Tempfile.create([ "test", ".xml" ]) do |f|
      f.write(xml)
      f.flush
      yield Importer::Sources::GameMaster5Xml::Document.new(f.path)
    end
  end

  def open_files_for(path)
    ObjectSpace.each_object(File).count { |file| file.path == path && !file.closed? }
  end
end
