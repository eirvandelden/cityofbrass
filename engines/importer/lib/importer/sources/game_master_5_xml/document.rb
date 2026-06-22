require "nokogiri"
require_relative "pc_name_parser"
require_relative "attack_notation_parser"

module Importer
  module Sources
    class GameMaster5Xml
      # Parses a Game Master 5 / FightClub5 XML file into plain record hashes
      # (one per compendium entity, campaign, or character) for the importer.
      class Document
        def initialize(path)
          File.open(path) do |file|
            @document = Nokogiri::XML(file) { |config| config.strict.noblanks }
          end
        end

        def compendium_records
          monster_records + item_records + container_records + item_template_records +
            spell_records + rule_records + class_records + subclass_records
        end

        def campaign_record
          node = campaign_node
          return {} if node.blank?

          {
            name: text_at(node, "name"),
            adventures: nodes(node, "./adventure").map { |adventure| adventure_record(adventure) },
            encounters: nodes(node, "./encounter").map { |encounter| encounter_record(encounter) },
            page_records: page_records(node),
            content_items: campaign_content_items(node),
            monsters: campaign_monster_records(node),
            items: campaign_item_records(node),
            notes: nodes(node, "./note").map { |note| note_record(note) },
            pcs: nodes(node, ".//pc").map { |pc| pc_campaign_record(pc) },
            npcs: nodes(node, "./npc").map { |npc| npc_record(npc) }
          }
        end

        def character_records
          character_pc_nodes.map { |pc| character_record(pc) } +
            character_npc_nodes.map { |npc| npc_record(npc) }
        end

        private

        attr_reader :document

        def character_pc_nodes
          return [ character_node(root) ] if root.name == "pc"
          return nodes(root, "./pc").map { |pc| character_node(pc) } if root.name == "characters"

          []
        end

        # GM5-native PC files wrap the stat block in a <character> element;
        # FightClub flat <pc> files do not.
        def character_node(pc)
          pc.at_xpath("./character") || pc
        end

        def character_npc_nodes
          return [ root ] if root.name == "npc"
          return nodes(root, "./npc") if root.name == "characters"

          []
        end

        # ---------------------------------------------------------------------------
        # Compendium entity records
        # ---------------------------------------------------------------------------

        def monster_records
          nodes(root, "./monster").map { |node| monster_record(node) }
        end

        def item_records
          nodes(root, "./item").map { |node| item_record("item", node) }
        end

        def container_records
          nodes(root, "./container").map { |node| item_record("container", node) }
        end

        def item_template_records
          nodes(root, "./itemtemplate").map { |node| item_record("item", node) }
        end

        def spell_records
          nodes(root, "./spell").map { |node| spell_record(node) }
        end

        def rule_records
          race_records + background_records + feat_records
        end

        def race_records
          nodes(root, "./race").map { |node| race_record(node) }
        end

        def background_records
          nodes(root, "./background").map { |node| background_record(node) }
        end

        def feat_records
          nodes(root, "./feat").map { |node| feat_record(node) }
        end

        def class_records
          nodes(root, "./baseclass | ./class").map { |baseclass| class_record(baseclass) }
        end

        def subclass_records
          nodes(root, "./subclass").map { |subclass| subclass_record(subclass) }
        end

        # ---------------------------------------------------------------------------
        # Individual entity builders
        # ---------------------------------------------------------------------------

        def monster_record(node)
          {
            type: "monster",
            name: text_at(node, "name"),
            description: text_at(node, "description"),
            size: text_at(node, "size"),
            creature_type: text_at(node, "type"),
            alignment: text_at(node, "alignment"),
            ac: text_at(node, "ac"),
            hp: text_at(node, "hp").presence || text_at(node, "hpMax"),
            speed: text_at(node, "speed"),
            str: ability_at(node, :str),
            dex: ability_at(node, :dex),
            con: ability_at(node, :con),
            int: ability_at(node, :int),
            wis: ability_at(node, :wis),
            cha: ability_at(node, :cha),
            saves: nodes(node, "./save").map(&:text),
            skills: nodes(node, "./skill").map(&:text),
            passive: text_at(node, "passive"),
            senses: text_at(node, "senses"),
            immune: text_at(node, "immune"),
            resist: text_at(node, "resist"),
            vulnerable: text_at(node, "vulnerable"),
            condition: text_at(node, "conditionImmune"),
            languages: text_at(node, "languages"),
            cr: text_at(node, "cr"),
            environment: text_at(node, "environment"),
            traits: named_text_nodes(node, "./trait"),
            actions: action_nodes(node, "./action"),
            reactions: action_nodes(node, "./reaction"),
            legendary: action_nodes(node, "./legendary"),
            spell_ability: text_at(node, "spellAbility"),
            spells: text_at(node, "spells"),
            slots: text_at(node, "slots"),
            source: source
          }
        end

        def item_record(type, node)
          {
            type: type,
            name: text_at(node, "name"),
            item_type: text_at(node, "type"),
            detail: text_at(node, "detail"),
            value: text_at(node, "value"),
            weight: text_at(node, "weight"),
            dmg1: text_at(node, "dmg1"),
            dmg2: text_at(node, "dmg2"),
            dmg_type: text_at(node, "dmgType"),
            property: text_at(node, "property"),
            ac: text_at(node, "ac"),
            range: text_at(node, "range"),
            strength: text_at(node, "strength"),
            stealth: text_at(node, "stealth"),
            magic: text_at(node, "magic"),
            text: nodes(node, "./text").map(&:text),
            source: source
          }
        end

        def spell_record(node)
          {
            type: "spell",
            name: text_at(node, "name"),
            level: text_at(node, "level"),
            school: text_at(node, "school"),
            ritual: text_at(node, "ritual").to_s.upcase == "YES",
            time: text_at(node, "time"),
            range: text_at(node, "range"),
            components: text_at(node, "components"),
            components_v: node.at_xpath("./components/v").present? || node.at_xpath("./v").present?,
            components_s: node.at_xpath("./components/s").present? || node.at_xpath("./s").present?,
            components_m: node.at_xpath("./components/m").present? || node.at_xpath("./m").present?,
            materials: text_at(node, "components/m").presence || text_at(node, "m"),
            duration: text_at(node, "duration"),
            text: nodes(node, "./text").map(&:text),
            classes: text_at(node, "classes"),
            source: source
          }
        end

        def race_record(node)
          {
            type: "race",
            name: text_at(node, "name"),
            size: text_at(node, "size"),
            speed: text_at(node, "speed"),
            abilities: nodes(node, "./ability").map(&:text),
            proficiencies: nodes(node, "./proficiency").map(&:text),
            traits: named_text_nodes(node, "./trait"),
            source: source
          }
        end

        def background_record(node)
          {
            type: "background",
            name: text_at(node, "name"),
            proficiencies: nodes(node, "./proficiency").map(&:text),
            traits: named_text_nodes(node, "./trait"),
            source: source
          }
        end

        def feat_record(node)
          {
            type: "feat",
            name: text_at(node, "name"),
            prerequisite: text_at(node, "prerequisite"),
            modifiers: nodes(node, "./modifier").map(&:text),
            text: nodes(node, "./text").map(&:text),
            source: source
          }
        end

        def class_record(baseclass)
          {
            type: "class",
            name: text_at(baseclass, "name"),
            hd: text_at(baseclass, "hd"),
            proficiencies: nodes(baseclass, "./proficiency").map(&:text),
            armor: text_at(baseclass, "armor"),
            weapons: text_at(baseclass, "weapons"),
            tools: text_at(baseclass, "tools"),
            num_skills: text_at(baseclass, "numSkills"),
            text: text_at(baseclass, "text"),
            subclass_names: subclass_names_for(baseclass),
            source: source
          }
        end

        def subclass_record(subclass)
          {
            type: "subclass",
            name: text_at(subclass, "name"),
            baseclass: subclass["baseclass"],
            traits: named_text_nodes(subclass, "./trait"),
            text: nodes(subclass, "./text").map(&:text),
            source: source
          }
        end

        # ---------------------------------------------------------------------------
        # Campaign entity records
        # ---------------------------------------------------------------------------

        def campaign_monster_records(node)
          nodes(node, ".//combatant/monster")
            .map { |monster| monster_record(monster) }
            .reject { |record| record[:name].blank? }
            .uniq { |record| record[:name].downcase }
        end

        def campaign_item_records(node)
          nodes(node, "./item").map { |item| item_record("item", item) } +
            nodes(node, "./container").map { |container| item_record("container", container) }
        end

        def adventure_record(adventure)
          {
            type: "adventure",
            name: name_or_title(adventure),
            description: text_at(adventure, "text"),
            encounters: page_records(adventure),
            npcs: nodes(adventure, ".//npc").map { |npc| npc_record(npc) }
          }
        end

        def campaign_content_items(node)
          nodes(node, "./adventure | ./encounter | ./note").map do |child|
            case child.name
            when "adventure" then adventure_record(child)
            when "note" then note_record(child)
            else encounter_record(child)
            end
          end
        end

        def page_records(node)
          nodes(node, "./encounter | ./note").map do |page|
            page.name == "note" ? note_record(page) : encounter_record(page)
          end
        end

        def encounter_record(node)
          text_blocks = nodes(node, "./text | .//note/text").map(&:text)
          {
            type: "encounter",
            name: name_or_title(node),
            description: text_blocks.join("\n"),
            text: text_blocks,
            combatants: nodes(node, "./combatant").map { |c| combatant_record(c) }.reject { |c| c[:name].blank? }
          }
        end

        def note_record(node)
          text_blocks = nodes(node, "./text").map(&:text)
          {
            type: "note",
            name: name_or_title(node),
            description: text_blocks.join("\n"),
            text: text_blocks
          }
        end

        def npc_record(node)
          {
            type: "npc",
            name: text_at(node, "label").presence || text_at(node, "name"),
            size: text_at(node, "size"),
            hp: text_at(node, "hp"),
            ac: text_at(node, "ac"),
            npc_type: text_at(node, "type"),
            alignment: text_at(node, "alignment"),
            cr: text_at(node, "cr"),
            description: text_at(node, "description"),
            source: source
          }
        end

        def pc_campaign_record(node)
          {
            type: "pc",
            label: text_at(node, "label"),
            name: text_at(node, "label").presence || text_at(node, "name"),
            description: text_at(node, "description")
          }
        end

        # ---------------------------------------------------------------------------
        # Character file PC record
        # ---------------------------------------------------------------------------

        def character_record(node)
          {
            type: "pc",
            label: text_at(node, "label"),
            name: text_at(node, "name"),
            size: text_at(node, "size"),
            ac: text_at(node, "ac"),
            hp: text_at(node, "hp").presence || text_at(node, "hpMax"),
            speed: text_at(node, "speed"),
            str: ability_at(node, :str),
            dex: ability_at(node, :dex),
            con: ability_at(node, :con),
            int: ability_at(node, :int),
            wis: ability_at(node, :wis),
            cha: ability_at(node, :cha),
            race_name: text_at(node, "race/name"),
            class_name: text_at(node, "class/name"),
            class_level: text_at(node, "class/level"),
            classes: nodes(node, "./class").map { |c|
              {
                name: text_at(c, "name"),
                level: text_at(c, "level"),
                hd: text_at(c, "hd"),
                hd_current: text_at(c, "hdCurrent"),
                slots: text_at(c, "slots")
              }
            },
            armor_name: text_at(node, "armor"),
            saves: nodes(node, "./save").map(&:text),
            skills: nodes(node, "./skill").map(&:text),
            passive: text_at(node, "passive"),
            senses: text_at(node, "senses"),
            languages: text_at(node, "languages"),
            actions: action_nodes(node, "./action"),
            spells: nodes(node, "./spell").map(&:text),
            items: nodes(node, "./item").map { |item| { name: text_at(item, "name"), quantity: text_at(item, "quantity") } },
            source: source
          }
        end

        # ---------------------------------------------------------------------------
        # Shared helpers
        # ---------------------------------------------------------------------------

        def named_text_nodes(parent, xpath)
          nodes(parent, xpath).map do |child|
            {
              name: text_at(child, "name"),
              text: text_at(child, "text"),
              recharge: text_at(child, "recharge"),
              attack: action_attack(child)
            }
          end
        end

        def action_nodes(parent, xpath)
          nodes(parent, xpath).map do |child|
            { name: text_at(child, "name"), text: text_at(child, "text"), attack: action_attack(child) }
          end
        end

        def action_attack(action_node)
          attack = action_node.at_xpath("./attack")

          if attack.nil?
            atk = text_at(action_node, "atk")
            dmg = text_at(action_node, "dmg")
            return "" unless atk.present? || dmg.present?

            name = text_at(action_node, "name")
            return "#{name}|+#{atk}|#{dmg}"
          end

          atk = text_at(attack, "atk")
          dmg = text_at(attack, "dmg")

          if atk.present? || dmg.present?
            name = text_at(attack, "name")
            "#{name}|+#{atk}|#{dmg}"
          else
            attack.text.strip
          end
        end

        def ability_at(node, ability)
          text_at(node, ability.to_s).presence || split_abilities(node)[ability_names.index(ability)]
        end

        def split_abilities(node)
          text_at(node, "abilities").split(",").map(&:strip)
        end

        def ability_names
          %i[str dex con int wis cha]
        end

        def combatant_record(node)
          monster_node = node.at_xpath("./monster")
          return { name: nil } if monster_node.nil?

          if monster_node.element_children.any?
            record = monster_record(monster_node)
            { name: record[:name], inline_monster: record }
          else
            { name: monster_node.text.strip }
          end
        end

        def subclass_names_for(baseclass)
          name = text_at(baseclass, "name")
          root.xpath("./subclass[@baseclass=$name]", nil, name: name).map { |subclass| text_at(subclass, "name") }
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

        def name_or_title(node)
          text_at(node, "name").presence || text_at(node, "title")
        end

        def root
          document.root
        end
      end
    end
  end
end
