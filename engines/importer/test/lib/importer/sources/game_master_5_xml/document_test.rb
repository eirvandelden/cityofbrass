require_relative "../../../../test_helper"

class ImporterGameMaster5XmlDocumentTest < ActiveSupport::TestCase
  # rubocop:disable Metrics/BlockLength
  test "monster record extracts all stat fields" do
    xml = <<~XML
      <compendium>
        <monster>
          <name>Test Goblin</name>
          <size>S</size>
          <type>humanoid (goblinoid)</type>
          <ac>15 (leather armor)</ac>
          <hp>7 (2d6)</hp>
          <speed>30 ft.</speed>
          <str>8</str><dex>14</dex><con>10</con>
          <int>10</int><wis>8</wis><cha>8</cha>
          <save>Dex +4</save>
          <skill>Stealth +6</skill>
          <senses>darkvision 60 ft., passive Perception 9</senses>
          <immune>poison</immune>
          <resist>fire</resist>
          <languages>Common, Goblin</languages>
          <cr>1/4</cr>
          <trait><name>Nimble Escape</name><text>The goblin can Disengage.</text></trait>
          <action><name>Scimitar</name><text>Melee Weapon Attack.</text><attack>Scimitar|+4|1d6+2</attack></action>
        </monster>
      </compendium>
    XML

    document_for(xml) do |doc|
      records = doc.compendium_records
      assert_equal 1, records.size
      monster = records.first
      assert_equal "monster", monster[:type]
      assert_equal "Test Goblin", monster[:name]
      assert_equal "S", monster[:size]
      assert_equal "humanoid (goblinoid)", monster[:creature_type]
      assert_equal "15 (leather armor)", monster[:ac]
      assert_equal "7 (2d6)", monster[:hp]
      assert_equal "8", monster[:str]
      assert_equal "14", monster[:dex]
      assert_equal [ "Dex +4" ], monster[:saves]
      assert_equal [ "Stealth +6" ], monster[:skills]
      assert_equal "1/4", monster[:cr]
      assert_equal "poison", monster[:immune]
      assert_equal 1, monster[:traits].size
      assert_equal "Nimble Escape", monster[:traits].first[:name]
      assert_equal 1, monster[:actions].size
      assert_equal "Scimitar", monster[:actions].first[:name]
      assert_equal "Scimitar|+4|1d6+2", monster[:actions].first[:attack]
    end
  end
  # rubocop:enable Metrics/BlockLength

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

  # rubocop:disable Metrics/BlockLength
  test "character_records parses standalone PC file" do
    xml = <<~XML
      <pc version="5">
        <label>Quinthya</label>
        <name>Elf (Wood) Monk 2</name>
        <size>M</size>
        <ac>15</ac>
        <hp>14 (2d8)</hp>
        <speed>30 ft.</speed>
        <str>10</str><dex>16</dex><con>12</con>
        <int>10</int><wis>14</wis><cha>8</cha>
        <save>Strength +2</save>
        <save>Dexterity +5</save>
        <skill>Acrobatics +5</skill>
        <skill>Perception +4</skill>
        <senses>passive Perception 14</senses>
        <languages>Common, Elvish</languages>
        <passive>14</passive>
        <action>
          <name>Unarmed Strike</name>
          <text>Melee Weapon Attack.</text>
          <attack>Unarmed Strike|+5|1d4+3</attack>
        </action>
      </pc>
    XML

    document_for(xml) do |doc|
      records = doc.character_records
      assert_equal 1, records.size
      pc = records.first
      assert_equal "pc", pc[:type]
      assert_equal "Quinthya", pc[:label]
      assert_equal "Elf (Wood) Monk 2", pc[:name]
      assert_equal "M", pc[:size]
      assert_equal "15", pc[:ac]
      assert_equal "14 (2d8)", pc[:hp]
      assert_equal "10", pc[:str]
      assert_equal "16", pc[:dex]
      assert_equal [ "Strength +2", "Dexterity +5" ], pc[:saves]
      assert_equal [ "Acrobatics +5", "Perception +4" ], pc[:skills]
      assert_equal 1, pc[:actions].size
      assert_equal "Unarmed Strike|+5|1d4+3", pc[:actions].first[:attack]
    end
  end
  # rubocop:enable Metrics/BlockLength

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

  def document_for(xml)
    Tempfile.create([ "test", ".xml" ]) do |f|
      f.write(xml)
      f.flush
      yield Importer::Sources::GameMaster5Xml::Document.new(f.path)
    end
  end
end
