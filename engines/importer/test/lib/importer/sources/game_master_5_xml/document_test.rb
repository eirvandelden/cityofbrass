require_relative "../../../../test_helper"

class ImporterGameMaster5XmlDocumentTest < ActiveSupport::TestCase
  test "monster record extracts all stat fields" do
    document = Importer::Sources::GameMaster5Xml::Document.new(importer_fixture_file("sample_compendium.xml"))

    assert_monster_record document.compendium_records.find { |record| record[:name] == "Goblin" }
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
