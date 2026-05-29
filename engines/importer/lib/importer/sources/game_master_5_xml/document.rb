require "nokogiri"

module Importer
  module Sources
    class GameMaster5Xml
      class Document
        def initialize(path)
          @document = Nokogiri::XML(File.open(path)) { |config| config.strict.noblanks }
        end

        def compendium_records
          records_for("monster", "monster") + records_for("item", "item") + records_for("container", "item") +
            records_for("spell", "spell") + rule_records + class_records
        end

        def campaign_record
          node = campaign_node
          return {} if node.blank?

          {
            name: text_at(node, "name"),
            adventures: nodes(node, "./adventure").map { |adventure| adventure_record(adventure) },
            notes: records_for("note", "note", node),
            pcs: nodes(node, ".//pc").map { |pc| { type: "pc", name: text_at(pc, "label").presence || text_at(pc, "name") } },
            npcs: records_for("npc", "npc", node)
          }
        end

        private

        attr_reader :document

        def records_for(xml_name, type, node = root)
          nodes(node, "./#{xml_name}").map { |record| named_record(type, record) }
        end

        def rule_records
          records_for("race", "race") + records_for("background", "background") + records_for("feat", "feat")
        end

        def class_records
          nodes(root, "./baseclass").map do |baseclass|
            named_record("class", baseclass).merge(description: subclass_names_for(baseclass).join(", "))
          end
        end

        def adventure_record(adventure)
          named_record("adventure", adventure).merge(encounters: records_for("encounter", "encounter", adventure))
        end

        def named_record(type, node)
          { type: type, name: text_at(node, "name"), description: text_at(node, "text"), source: source }
        end

        def subclass_names_for(baseclass)
          nodes(root, "./subclass[@baseclass='#{text_at(baseclass, "name")}']").map { |subclass| text_at(subclass, "name") }
        end

        def campaign_node
          return root if root.name == "campaign"

          root.at_xpath("./campaign")
        end

        def source
          @source ||= root.attributes.values.map(&:value).presence&.join(", ")
        end

        def nodes(node, xpath)
          node.xpath(xpath)
        end

        def text_at(node, xpath)
          node.at_xpath(xpath)&.text.to_s.strip
        end

        def root
          document.root
        end
      end
    end
  end
end
