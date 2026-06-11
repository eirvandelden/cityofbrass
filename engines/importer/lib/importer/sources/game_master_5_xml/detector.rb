require "nokogiri"

module Importer
  module Sources
    class GameMaster5Xml
      class Detector
        def initialize(io)
          @io = io
        end

        def kind
          return "unsupported" if document.root.blank?

          detect_root(document.root)
        rescue Nokogiri::XML::SyntaxError
          "unsupported"
        ensure
          rewind
        end

        def entity_counts
          return {} if document.root.blank?

          case kind
          when "compendium"
            compendium_counts(document.root)
          when "campaign"
            campaign_counts(campaign_node)
          when "characters"
            characters_counts(document.root)
          when "pc"
            { "pcs" => 1 }
          else
            {}
          end
        rescue Nokogiri::XML::SyntaxError
          {}
        ensure
          rewind
        end

        private

        attr_reader :io

        def document
          @document ||= Nokogiri::XML(io) { |config| config.strict.noblanks }
        end

        def detect_root(root)
          return root.name if %w[compendium characters pc].include?(root.name)
          return "campaign" if root.name == "campaign"
          return "campaign" if root.name == "data" && root.at_xpath("./campaign").present?

          "unsupported"
        end

        def compendium_counts(root)
          {
            "monsters" => root.xpath("./monster").size,
            "items" => root.xpath("./item | ./container").size,
            "spells" => root.xpath("./spell").size,
            "races" => root.xpath("./race").size,
            "backgrounds" => root.xpath("./background").size,
            "feats" => root.xpath("./feat").size,
            "classes" => root.xpath("./baseclass").size,
            "subclasses" => root.xpath("./subclass").size
          }
        end

        def campaign_counts(node)
          return {} if node.blank?

          {
            "adventures" => node.xpath(".//adventure").size,
            "encounters" => node.xpath(".//encounter").size,
            "monsters" => campaign_monster_names(node).size,
            "items" => node.xpath("./item | ./container").size,
            "notes" => node.xpath("./note").size,
            "pcs" => node.xpath(".//pc").size,
            "npcs" => node.xpath(".//npc").size,
            "combatants" => node.xpath(".//combatant").size
          }
        end

        def campaign_monster_names(node)
          node.xpath(".//combatant/monster")
            .filter_map { |monster| monster_name(monster) }
            .uniq(&:downcase)
        end

        def monster_name(node)
          name = node.at_xpath("./name")&.text.to_s.strip
          name.presence || node.text.to_s.strip.presence
        end

        def characters_counts(root)
          {
            "pcs" => root.xpath("./pc").size,
            "npcs" => root.xpath("./npc").size
          }
        end

        def campaign_node
          return document.root if document.root.name == "campaign"

          document.root.at_xpath("./campaign")
        end

        def rewind
          io.rewind if io.respond_to?(:rewind)
        end
      end
    end
  end
end
