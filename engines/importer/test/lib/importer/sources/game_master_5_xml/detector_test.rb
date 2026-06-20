require_relative "../../../../test_helper"

class ImporterGameMaster5XmlDetectorTest < ActiveSupport::TestCase
  test "detects compendium XML by root element" do
    detector = Importer::Sources::GameMaster5Xml::Detector.new(xml("<compendium version='5'><monster /></compendium>"))

    assert_equal "compendium", detector.kind
  end

  test "detects campaign XML nested under data" do
    detector = Importer::Sources::GameMaster5Xml::Detector.new(xml("<data><campaign><name>Red Hand</name></campaign></data>"))

    assert_equal "campaign", detector.kind
  end

  test "counts campaign items and embedded monsters" do
    file = File.open(importer_fixture_file("sample_campaign_with_embedded_content.xml"))
    detector = Importer::Sources::GameMaster5Xml::Detector.new(file)

    assert_equal 1, detector.entity_counts["items"]
    assert_equal 1, detector.entity_counts["monsters"]
  ensure
    file&.close
  end

  test "detects standalone PC XML" do
    detector = Importer::Sources::GameMaster5Xml::Detector.new(xml("<pc version='5'><name>Elf Monk 2</name></pc>"))

    assert_equal "pc", detector.kind
  end

  test "detects characters XML and counts pcs and npcs" do
    detector = Importer::Sources::GameMaster5Xml::Detector.new(
      xml("<characters version='5'><pc><name>A</name></pc><npc><name>B</name></npc></characters>")
    )

    assert_equal "characters", detector.kind
    assert_equal 1, detector.entity_counts["pcs"]
    assert_equal 1, detector.entity_counts["npcs"]
  end

  test "detects campaign XML at the document root" do
    detector = Importer::Sources::GameMaster5Xml::Detector.new(xml("<campaign><name>Red Hand</name></campaign>"))

    assert_equal "campaign", detector.kind
  end

  test "marks data XML without a campaign as unsupported" do
    detector = Importer::Sources::GameMaster5Xml::Detector.new(xml("<data><settings /></data>"))

    assert_equal "unsupported", detector.kind
  end

  test "marks aggregator and note roots as unsupported" do
    %w[collection source notes].each do |root|
      detector = Importer::Sources::GameMaster5Xml::Detector.new(xml("<#{root}><name>X</name></#{root}>"))
      assert_equal "unsupported", detector.kind, "expected <#{root}> to be unsupported"
    end
  end

  test "marks malformed XML as unsupported" do
    detector = Importer::Sources::GameMaster5Xml::Detector.new(xml("<compendium><monster></compendium>"))

    assert_equal "unsupported", detector.kind
    assert_equal({}, detector.entity_counts)
  end

  test "marks unsupported XML roots" do
    detector = Importer::Sources::GameMaster5Xml::Detector.new(xml("<template><monster /></template>"))

    assert_equal "unsupported", detector.kind
  end

  private

  def xml(body)
    StringIO.new(body)
  end
end
