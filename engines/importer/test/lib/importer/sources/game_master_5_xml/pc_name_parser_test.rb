require_relative "../../../../test_helper"

class ImporterGameMaster5XmlPcNameParserTest < ActiveSupport::TestCase
  Parser = Importer::Sources::GameMaster5Xml::PcNameParser

  test "parses race, class, and level" do
    assert_equal({ race: "Half-Orc", class_name: "Barbarian", level: 5 }, Parser.parse("Half-Orc Barbarian 5"))
  end

  test "parses a parenthesized race qualifier" do
    assert_equal({ race: "Elf (Wood)", class_name: "Monk", level: 2 }, Parser.parse("Elf (Wood) Monk 2"))
  end

  test "returns nil when there is no trailing level" do
    assert_nil Parser.parse("Human Rogue")
  end

  test "returns nil for a single word" do
    assert_nil Parser.parse("Wizard")
  end

  test "returns nil for blank input" do
    assert_nil Parser.parse("")
    assert_nil Parser.parse(nil)
  end
end
