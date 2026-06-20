require_relative "../../../../test_helper"

class ImporterGameMaster5XmlAttackNotationParserTest < ActiveSupport::TestCase
  Parser = Importer::Sources::GameMaster5Xml::AttackNotationParser

  test "parses a named attack with bonus and damage" do
    assert_equal({ name: "Scimitar", bonus: "+4", damage: "1d6+2" }, Parser.parse("Scimitar|+4|1d6+2"))
  end

  test "parses a nameless attack" do
    assert_equal({ name: "", bonus: "+3", damage: "1d6+1" }, Parser.parse("|+3|1d6+1"))
  end

  test "returns nil when there are fewer than three segments" do
    assert_nil Parser.parse("Scimitar|+4")
  end

  test "returns nil for a string without pipes" do
    assert_nil Parser.parse("just text")
  end

  test "returns nil for blank input" do
    assert_nil Parser.parse("")
    assert_nil Parser.parse(nil)
  end
end
