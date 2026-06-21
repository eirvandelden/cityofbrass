module Importer
  class Import
    # Turns parsed Game Master 5 records into native City of Brass records
    # (creatures, items, spells, rules, campaigns, characters, and NPCs).
    module Processing
      extend ActiveSupport::Concern

      CORE_RULES = "dnd5e"
      LOCAL_NAME_LIMIT = 64

      def process!
        update!(status: "running", started_at: Time.current)
        prepare_files_from_preview! if import_files.empty?
        raise ArgumentError, "no import files available" if import_files.empty?

        ordered_import_files.each { |import_file| process_import_file_safely(import_file) }
        finish!
      rescue StandardError => error
        update!(status: "failed", finished_at: Time.current, summary: { "error" => error.message })
      end

      def prepare_files_from_preview!
        return if preview.blank?

        preview.preview_files.find_each { |preview_file| copy_preview_file(preview_file) }
      end

      private

      def copy_preview_file(preview_file)
        File.open(preview_file.file.path) do |file|
          import_files.create!(kind: preview_file.kind, parse_status: "pending", file: file)
        end
      end

      def ordered_import_files
        import_files.sort_by { |import_file| %w[compendium characters pc campaign unsupported].index(import_file.kind) || 99 }
      end

      def process_import_file_safely(import_file)
        process_import_file(import_file)
      rescue StandardError => error
        import_file.import_results.create!(
          entity_type: import_file.kind,
          entity_name: import_file.file_file_name,
          outcome: "failed",
          reason: error.message
        )
        import_file.update!(parse_status: "failed")
      end

      def process_import_file(import_file)
        return unsupported_import_file(import_file) if import_file.kind == "unsupported"

        document = Sources::GameMaster5Xml::Document.new(import_file.file.path)
        if import_file.kind == "campaign"
          import_campaign(import_file, document)
          import_file.update!(parse_status: "parsed")
          return
        end

        if import_file.kind == "compendium"
          import_compendium(import_file, document)
          import_file.update!(parse_status: "parsed")
          return
        end

        if import_file.kind.in?(%w[characters pc])
          process_character_file(import_file, document)
          import_file.update!(parse_status: "parsed")
          return
        end

        unsupported_import_file(import_file)
      end

      def import_compendium(import_file, document)
        document.compendium_records.each { |record| import_record_safely(import_file, record) { import_compendium_record(import_file, record) } }
      end

      def process_character_file(import_file, document)
        document.character_records.each { |record| import_record_safely(import_file, record) { import_character_record(import_file, record) } }
      end

      # Runs a single record import in isolation so one malformed entity does not
      # abort the rest of the file. Blank-named records are still imported (with a
      # unique "No Name N" placeholder); only genuinely invalid records are logged
      # as failures.
      def import_record_safely(import_file, record)
        yield
      rescue ActiveRecord::RecordInvalid => error
        result(import_file, record, "failed", nil, error.message)
      end

      def import_character_record(import_file, record)
        return import_character(import_file, record) if record[:type] == "pc"

        import_npc(import_file, record) if record[:type] == "npc"
      end

      def unsupported_import_file(import_file)
        import_file.import_results.create!(
          entity_type: import_file.kind,
          entity_name: import_file.file_file_name,
          outcome: "failed",
          reason: "unsupported file kind"
        )
        import_file.update!(parse_status: "failed")
      end

      def import_compendium_record(import_file, record)
        case record[:type]
        when "monster" then import_monster(import_file, record)
        when "item", "container" then import_item(import_file, record)
        when "spell" then import_spell(import_file, record)
        when "race", "background", "feat", "class", "subclass" then import_rule(import_file, record)
        end
      end

      def import_campaign(import_file, document)
        campaign = document.campaign_record
        return if campaign.blank?

        return import_stock_campaign(import_file, campaign) if admin_stock?

        root = resident_campaign(import_file, campaign)
        with_campaign_import_tracking(root) do
          import_campaign_monsters(import_file, campaign)
          import_campaign_items(import_file, campaign)
          menu_records = import_ordered_campaign_content(import_file, campaign, root)
          rebuild_campaign_menu(root, menu_records, [])
          campaign[:pcs].each { |pc| import_pc(import_file, pc) }
          campaign[:npcs].each { |npc| link_campaign_notable(root, import_npc(import_file, npc)) }
        end
      end

      def import_ordered_campaign_content(import_file, campaign, root)
        items = campaign.fetch(:content_items, nil)
        return fallback_campaign_content(import_file, campaign, root) if items.nil?

        menu_records = []
        pending_pages = []

        items.each do |item|
          if item[:type] == "adventure"
            unless pending_pages.empty?
              loose_adv = import_loose_campaign_pages(import_file, campaign.merge(page_records: pending_pages, encounters: [], notes: []), root)
              menu_records << loose_adv if loose_adv
              pending_pages = []
            end
            menu_records << import_adventure(import_file, item, root)
          else
            pending_pages << item
          end
        end

        unless pending_pages.empty?
          loose_adv = import_loose_campaign_pages(import_file, campaign.merge(page_records: pending_pages, encounters: [], notes: []), root)
          menu_records << loose_adv if loose_adv
        end

        menu_records.compact
      end

      def fallback_campaign_content(import_file, campaign, root)
        adventures = explicit_campaign_adventures(campaign).map { |adventure| import_adventure(import_file, adventure, root) }
        loose_adventure = import_loose_campaign_pages(import_file, campaign, root)
        (adventures + [ loose_adventure ]).compact
      end

      def import_stock_campaign(import_file, campaign)
        with_campaign_import_tracking(nil) do
          import_campaign_monsters(import_file, campaign)
          import_campaign_items(import_file, campaign)
          adventures = campaign_adventures(import_file, campaign).map { |adventure| import_stock_adventure(import_file, adventure) }
          root = adventures.first || stock_adventure(import_file, { name: campaign_name(import_file, campaign) })
          stock_note_pages = campaign_stock_notes(campaign).map { |note| import_stock_note(import_file, note, root) }

          rebuild_adventure_menu(root, root.pages.order(:created_at)) if stock_note_pages.any?
          campaign[:pcs].each { |pc| import_pc(import_file, pc) }
          campaign[:npcs].each { |npc| import_npc(import_file, npc) }
        end
      end

      def import_campaign_monsters(import_file, campaign)
        campaign.fetch(:monsters, []).each { |record| import_monster(import_file, record) }
      end

      def import_campaign_items(import_file, campaign)
        campaign.fetch(:items, []).each { |record| import_item(import_file, record) }
      end

      def explicit_campaign_adventures(campaign)
        campaign.fetch(:adventures, [])
      end

      def loose_campaign_page_records(campaign)
        campaign.fetch(:page_records, campaign.fetch(:encounters, []) + campaign.fetch(:notes, []))
      end

      def import_loose_campaign_pages(import_file, campaign, root)
        page_records = loose_campaign_page_records(campaign)
        return nil if page_records.blank?

        adventure = resident_adventure(import_file, { type: "adventure", name: campaign_name(import_file, campaign) }, root)
        pages = page_records.map { |record| import_page_record(import_file, record, adventure) }
        rebuild_adventure_menu(adventure, pages)
        link_campaign_page_notables(root, pages)
        adventure
      end

      def campaign_adventures(import_file, campaign)
        return campaign[:adventures] if campaign[:adventures].present?

        page_records = campaign.fetch(:page_records, campaign.fetch(:encounters, []) + campaign.fetch(:notes, []))
        return [] if page_records.blank?

        [ { type: "adventure", name: campaign_name(import_file, campaign), encounters: page_records } ]
      end

      def campaign_gm_notes(campaign)
        []
      end

      def campaign_stock_notes(campaign)
        return [] if campaign[:adventures].blank? && (campaign.fetch(:encounters, []) + campaign.fetch(:notes, [])).present?

        campaign[:notes]
      end

      def resident_campaign(import_file, campaign)
        name = campaign_name(import_file, campaign)
        existing = existing_record(Campaignmanager::Campaign, name)
        if existing
          return replace_or_skip(import_file, { type: "campaign", name: name }, existing, campaign: existing) do |record|
            record.update!(privacy: "Private", core_rules: CORE_RULES)
          end
        end

        record = Campaignmanager::Campaign.create!(resident: resident, name: name, privacy: "Private", core_rules: CORE_RULES)
        with_import_provenance_campaign(record) do
          result(import_file, { type: "campaign", name: name }, "created", record)
        end
        record
      end

      def campaign_name(import_file, campaign)
        local_name(campaign[:name].presence || File.basename(import_file.file_file_name.to_s, ".*").tr("_-", " "))
      end

      def stock_adventure(import_file, adventure)
        name = unique_local_name(adventure)
        existing = existing_record(Storybuilder::StockAdventure, name)
        if existing
          return replace_or_skip(import_file, adventure.merge(type: "adventure", name: name), existing) do |record|
            record.update!(privacy: "Residents", core_rules: CORE_RULES)
          end
        end

        record = Storybuilder::StockAdventure.create!(name: name, privacy: "Residents", core_rules: CORE_RULES)
        result(import_file, adventure.merge(type: "adventure"), "created", record)
        record
      end

      def import_stock_adventure(import_file, adventure)
        record = stock_adventure(import_file, adventure)
        pages = adventure[:encounters].map { |encounter| import_page_record(import_file, encounter, record) }
        rebuild_adventure_menu(record, pages)
        record
      end

      def import_adventure(import_file, adventure, root)
        record = resident_adventure(import_file, adventure, root)
        adventure.fetch(:npcs, []).each { |npc| link_entities_to_storybuilder_notableable(record, [ import_npc(import_file, npc) ]) }
        pages = adventure[:encounters].map { |encounter| import_page_record(import_file, encounter, record) }
        rebuild_adventure_menu(record, pages)
        link_adventure_page_notables(record, pages)
        record
      end

      def import_page_record(import_file, record, adventure)
        if record[:name].to_s.strip.blank?
          return nil
        end

        if record[:type] == "note"
          import_stock_note(import_file, record, adventure)
        else
          import_encounter(import_file, record, adventure)
        end
      rescue ActiveRecord::RecordInvalid => error
        result(import_file, record, "failed", nil, error.message)
        nil
      end

      def rebuild_campaign_menu(campaign, adventures, pages)
        records = adventures.compact + pages.compact
        return if records.blank?

        remove_menu_items(campaign, records)
        sort_order = next_menu_sort_order(campaign)
        records.each_with_index { |record, index| create_campaign_menu_item(campaign, record, sort_order + index) }
      end

      def rebuild_adventure_menu(adventure, pages)
        pages = pages.compact.uniq
        return if pages.blank?

        remove_menu_items(adventure, pages)
        sort_order = next_menu_sort_order(adventure)
        pages.each_with_index { |page, index| create_page_menu_item(adventure, page, sort_order + index) }
      end

      def remove_menu_items(menu_owner, records)
        records.each do |record|
          menu_item_joins_for(menu_owner, record).find_each do |join|
            menu_item = join.menu_item
            join.destroy!
            menu_item.destroy!
          end
        end
      end

      def menu_item_joins_for(menu_owner, record)
        Storybuilder::MenuItemJoin.joins(:menu_item).where(
          menu_item_joinable: record,
          storybuilder_menu_items: {
            menu_itemable_id: menu_owner.id,
            menu_itemable_type: menu_owner_polymorphic_types(menu_owner)
          }
        )
      end

      def menu_owner_polymorphic_types(menu_owner)
        [ menu_owner.class.name, menu_owner.class.base_class.name ].uniq
      end

      def next_menu_sort_order(menu_owner)
        menu_owner.menu_items.maximum(:sort_order).to_i + 1
      end

      def create_campaign_menu_item(campaign, record, sort_order)
        menu_item = campaign.menu_items.create!(
          sort_order: sort_order,
          item_label: record.name.to_s.truncate(25),
          item_link: campaign_menu_link(campaign, record)
        )
        Storybuilder::MenuItemJoin.create!(menu_item: menu_item, menu_item_joinable: record)
      end

      def create_page_menu_item(adventure, page, sort_order)
        menu_item = adventure.menu_items.create!(
          sort_order: sort_order,
          item_label: page.name.to_s.truncate(25),
          item_link: "/pages/#{page.id}"
        )
        Storybuilder::MenuItemJoin.create!(menu_item: menu_item, menu_item_joinable: page)
      end

      def campaign_menu_link(campaign, record)
        path = storybuilder_path(record)
        record.is_a?(Storybuilder::Adventure) ? "#{path}/campaign/#{campaign.id}" : path
      end

      def storybuilder_path(record)
        adventure = storybuilder_adventure_for(record)
        "/sb/#{storybuilder_scope(adventure)}/adventures/#{adventure.id}#{storybuilder_page_path(record)}"
      end

      def storybuilder_adventure_for(record)
        return record if record.is_a?(Storybuilder::Adventure)

        Storybuilder::Adventure.find(record.adventure_id)
      end

      def storybuilder_scope(adventure)
        adventure.is_a?(Storybuilder::StockAdventure) ? "stock" : "resident"
      end

      def storybuilder_page_path(record)
        record.is_a?(Storybuilder::Page) ? "/pages/#{record.id}" : ""
      end

      def resident_adventure(import_file, adventure, campaign)
        name = unique_local_name(adventure)
        existing = existing_record(Storybuilder::ResidentAdventure, name)
        if existing
          link_adventure_to_campaign(campaign, existing)
          return replace_or_skip(import_file, adventure.merge(name: name), existing, campaign: campaign) do |record|
            record.update!(privacy: "Private", core_rules: CORE_RULES, full_description: adventure[:description].presence)
          end
        end

        record = Storybuilder::ResidentAdventure.create!(resident: resident, name: name, privacy: "Private",
                                                         core_rules: CORE_RULES,
                                                         full_description: adventure[:description].presence)
        link_adventure_to_campaign(campaign, record)
        result(import_file, adventure, "created", record)
        record
      end

      def link_adventure_to_campaign(campaign, adventure)
        return if campaign.campaign_adventure_joins.exists?(adventure: adventure)

        campaign.campaign_adventure_joins.create!(adventure: adventure, active: campaign_active_adventure_missing?(campaign))
      end

      def campaign_active_adventure_missing?(campaign)
        !campaign.campaign_adventure_joins.where(active: true).exists?
      end

      def import_encounter(import_file, encounter, adventure)
        name = unique_local_name(encounter)
        existing = existing_page(adventure, name)
        if existing
          return replace_or_skip(import_file, encounter.merge(name: name), existing, campaign: @import_provenance_campaign) do |record|
            record.update!(privacy: privacy, full_description: encounter[:description].presence)
            record.notables.destroy_all
            link_encounter_combatants(import_file, record, encounter[:combatants])
          end
        end

        record = Storybuilder::Page.create!(
          adventure: adventure,
          name: name,
          privacy: privacy,
          full_description: encounter[:description].presence
        )
        link_encounter_combatants(import_file, record, encounter[:combatants])
        result(import_file, encounter, "created", record)
        record
      end

      def link_encounter_combatants(import_file, page, combatants)
        return if combatants.blank?

        creature_class = admin_stock? ? Entitybuilder::StockCreature : Entitybuilder::ResidentCreature
        existing_entity_ids = page.notables.pluck(:entity_id).to_set

        combatants.each do |combatant|
          next if combatant[:name].blank?

          creature = name_index_find("monster", combatant[:name]) ||
                     existing_record(creature_class, combatant[:name])

          if creature.nil? && combatant[:inline_monster].present?
            creature = import_monster(import_file, combatant[:inline_monster])
          end

          next if creature.nil?
          next if existing_entity_ids.include?(creature.id)

          Storybuilder::Notable.create!(
            notableable: page,
            entity: creature,
            name: creature.name.truncate(64)
          )
          existing_entity_ids << creature.id
        rescue ActiveRecord::RecordInvalid
          # skip if notable already exists or invalid
        end
      end

      def import_note(import_file, note, root)
        return import_stock_note(import_file, note, root) if admin_stock?

        name = unique_local_name(note)
        existing = existing_note(root, name)
        if existing
          return replace_or_skip(import_file, note.merge(name: name), existing, campaign: root) do |record|
            record.update!(privacy: "Private", full_description: note[:description].presence)
          end
        end

        record = Campaignmanager::GameMasterNote.create!(
          campaign: root,
          name: name,
          privacy: "Private",
          full_description: note[:description].presence
        )
        result(import_file, note, "created", record)
        record
      end

      def import_stock_note(import_file, note, adventure)
        name = unique_local_name(note)
        existing = existing_page(adventure, name)
        if existing
          return replace_or_skip(import_file, note.merge(name: name), existing) do |record|
            record.update!(privacy: "Residents", tags: [ "note" ], full_description: nil)
            rebuild_note_sections(record, note)
          end
        end

        record = Storybuilder::Page.create!(
          adventure: adventure,
          name: name,
          privacy: "Residents",
          tags: [ "note" ],
          full_description: nil
        )
        rebuild_note_sections(record, note)
        result(import_file, note, "created", record)
        record
      end

      def rebuild_note_sections(page, note)
        page.sections.destroy_all
        Array(note[:text]).map(&:strip).reject(&:blank?).each_with_index do |text, index|
          page.sections.create!(section_type: "text", section_style: "paragraph", content: text, sort_order: index)
        end
      end

      def import_pc(import_file, pc)
        return result(import_file, pc, "skipped", nil, "no stock character target") if admin_stock?

        name = unique_local_name(pc)
        existing = existing_record(Entitybuilder::ResidentCharacter, name)
        if existing
          return replace_or_skip(import_file, pc.merge(name: name), existing) do |record|
            record.update!(full_description: pc[:description].presence)
            name_index_add("pc", pc[:label].presence || pc[:name], record)
          end
        end

        record = Entitybuilder::ResidentCharacter.create!(
          resident: resident,
          name: name,
          core_rules: CORE_RULES,
          full_description: pc[:description].presence
        )
        enforce_entity_privacy!(record)
        name_index_add("pc", pc[:label].presence || pc[:name], record)
        result(import_file, pc, "created", record)
      end

      def import_character(import_file, pc)
        return result(import_file, pc, "skipped", nil, "no stock character target") if admin_stock?

        label = pc[:label].presence || pc[:name]
        name = label.present? ? local_name(label) : unique_local_name(pc)
        existing = (label.present? ? name_index_find("pc", label) : nil) ||
                   existing_record(Entitybuilder::ResidentCharacter, name)

        if existing
          return replace_or_skip(import_file, pc.merge(name: name), existing) do |record|
            replace_character(record, pc)
            name_index_add("pc", label, record) if label.present?
          end
        end

        character = Entitybuilder::ResidentCharacter.create!(
          resident: resident,
          name: name,
          core_rules: CORE_RULES,
          full_description: pc[:description].presence
        )
        enforce_entity_privacy!(character)
        build_character_associations(character, pc)
        name_index_add("pc", label, character) if label.present?
        result(import_file, pc, "created", character)
      end

      def merge_character_stats(character, pc)
        return if character_has_stats?(character)

        build_ability_scores(character, pc)
        begin
          build_basic_stats(character, pc)
        rescue ActiveRecord::RecordInvalid
          # duplicate stats are ok during merge
        end
        build_character_name_info(character, pc)
        build_saves_and_skills(character, pc)
        build_creature_attacks(character, pc[:actions], "melee")
      end

      def character_has_stats?(character)
        character.ability_scores.exists?
      end

      def replace_character(character, pc)
        clear_entity_import_details(character)
        character.update!(full_description: pc[:description].presence)
        build_character_associations(character, pc)
        enforce_entity_privacy!(character)
      end

      def build_character_associations(character, pc)
        build_ability_scores(character, pc)
        build_basic_stats(character, pc)
        build_character_name_info(character, pc)
        build_saves_and_skills(character, pc)
        build_creature_attacks(character, pc[:actions], "melee")
        build_creature_spellcasting(character, pc)
        build_character_armor(character, pc)
      end

      def build_character_armor(character, pc)
        return if pc[:armor_name].blank?

        item = name_index_find("item", pc[:armor_name])
        if item
          begin
            character.inventory_items.create!(item: item, quantity: 1, equipped: true, carried: true)
          rescue ActiveRecord::RecordInvalid
            # skip if duplicate
          end
        else
          begin
            character.descriptors.create!(name: "Equipped Armor", description: pc[:armor_name].truncate(255))
          rescue ActiveRecord::RecordInvalid
            # skip if duplicate
          end
        end
      end

      def build_character_name_info(character, pc)
        parsed_name = Sources::GameMaster5Xml::PcNameParser.parse(pc[:name])
        race_value = pc[:race_name].presence || parsed_name&.dig(:race)
        class_name = pc[:class_name].presence || parsed_name&.dig(:class_name)
        class_level = pc[:class_level].presence&.to_i || parsed_name&.dig(:level)

        build_descriptors(character, [
          [ "Size", decode_size(pc[:size]) ],
          [ "Passive Perception", pc[:passive]&.to_s ],
          [ "Race", race_value ],
          [ "Senses", pc[:senses] ],
          [ "Languages", pc[:languages] ]
        ])
        link_race_rule(character, race_value)
        build_class_level(character, class_name, class_level)
        build_hit_dice(character, pc, class_level)
      end

      def link_race_rule(character, race_value)
        return if race_value.blank?

        race_rule = name_index_find("race", race_value)
        character.linked_rules.create!(rule: race_rule) if race_rule
      rescue ActiveRecord::RecordInvalid
        # skip duplicate linked rule
      end

      def build_class_level(character, class_name, class_level)
        return if class_name.blank?

        character.class_levels.create!(name: class_name, level: class_level || 1)
      rescue ActiveRecord::RecordInvalid
        # skip duplicate or invalid class level
      end

      def build_hit_dice(character, pc, class_level)
        hd_max = class_level.to_i
        return unless hd_max.positive? && pc[:hd].present?

        hd_current = pc[:hd_current].to_s.presence&.to_i || hd_max
        character.trackables.create!(name: "Hit Dice (#{pc[:hd]})", maximum: hd_max, current: hd_current)
      rescue ActiveRecord::RecordInvalid
        # skip duplicate hit dice trackable
      end

      def build_saves_and_skills(character, pc)
        split_stat_entries(pc[:saves]).each do |save_str|
          next unless (m = save_str.match(/\A(.+?)\s+([+\-]\d+)\z/))

          character.saving_throws.create!(name: m[1].strip, base: m[2].to_i)
        rescue ActiveRecord::RecordInvalid
          # skip if duplicate or validation error
        end

        split_stat_entries(pc[:skills]).each do |skill_str|
          next unless (m = skill_str.match(/\A(.+?)\s+([+\-]\d+)\z/))

          character.skills.create!(name: m[1].strip, bonus: m[2].to_i)
        rescue ActiveRecord::RecordInvalid
          # skip if duplicate or validation error
        end
      end

      # Saves/skills may arrive as separate elements or as one comma-separated
      # element (e.g. "Acrobatics +7, Arcana +6"). Normalise both into one list.
      def split_stat_entries(entries)
        Array(entries).flat_map { |entry| entry.to_s.split(",") }.map(&:strip).reject(&:blank?)
      end

      def import_npc(import_file, npc)
        klass = admin_stock? ? Entitybuilder::StockNpc : Entitybuilder::ResidentNpc
        name = unique_local_name(npc)
        existing = existing_record(klass, name)
        if existing
          return replace_or_skip(import_file, npc.merge(name: name), existing) do |record|
            replace_npc(record, npc)
          end
        end

        entity = klass.create!(
          name: name,
          core_rules: CORE_RULES,
          source: npc[:source],
          full_description: npc[:description].presence,
          **privacy_attributes_for(klass).merge(resident_content? ? { resident: resident } : {})
        )
        enforce_entity_privacy!(entity)
        build_npc_associations(entity, npc)
        result(import_file, npc, "created", entity)
        entity
      end

      def replace_npc(entity, npc)
        clear_entity_import_details(entity)
        entity.update!(
          source: npc[:source],
          full_description: npc[:description].presence,
          **privacy_attributes_for(entity.class)
        )
        build_npc_associations(entity, npc)
      end

      def build_npc_associations(entity, npc)
        build_descriptors(entity, [
          [ "Size", npc[:size] ],
          [ "Type", npc[:npc_type] ],
          [ "Alignment", npc[:alignment] ]
        ])
        build_basic_stats(entity, npc)
      end

      def import_monster(import_file, record)
        klass = admin_stock? ? Entitybuilder::StockCreature : Entitybuilder::ResidentCreature
        name = unique_local_name(record)
        existing = existing_record(klass, name)
        if existing
          name_index_add("monster", record[:name], existing)
          return replace_or_skip(import_file, record.merge(name: name), existing) do |creature|
            replace_creature(import_file, creature, record)
            name_index_add("monster", record[:name], creature)
          end
        end

        creature = klass.create!(
          name: name,
          core_rules: CORE_RULES,
          source: record[:source],
          short_description: record[:cr].presence,
          full_description: record[:description].presence,
          **privacy_attributes_for(klass).merge(resident_content? ? { resident: resident } : {})
        )
        enforce_entity_privacy!(creature)
        build_creature_associations(import_file, creature, record)
        name_index_add("monster", record[:name], creature)
        result(import_file, record, "created", creature)
      end

      def replace_creature(import_file, creature, record)
        clear_entity_import_details(creature)
        creature.update!(
          source: record[:source],
          short_description: record[:cr].presence,
          full_description: record[:description].presence,
          **privacy_attributes_for(creature.class)
        )
        build_creature_associations(import_file, creature, record)
      end

      def build_creature_associations(import_file, creature, record)
        build_ability_scores(creature, record)
        build_basic_stats(creature, record)
        build_saves_and_skills(creature, record)
        build_creature_descriptors(creature, record)
        build_creature_spellcasting(creature, record)
        build_creature_attacks(creature, record[:actions], "melee")
        build_creature_attacks(creature, record[:reactions], "melee")
        build_creature_attacks(creature, record[:legendary], "melee")
        build_creature_trait_rules(import_file, creature, record)
      end

      def build_creature_spellcasting(creature, record)
        build_descriptors(creature, [ [ "Spellcasting Ability", record[:spell_ability] ] ])
        build_spell_slots(creature, record[:slots])
        build_known_spells(creature, record[:spells])
      end

      def build_spell_slots(creature, slots)
        return if slots.blank?

        slots.split(",").each_with_index do |count, index|
          next if count.to_i.zero?

          creature.trackables.create!(name: spell_slot_name(index), maximum: count.to_i, current: count.to_i)
        rescue ActiveRecord::RecordInvalid
          # skip duplicate slot trackable
        end
      end

      def spell_slot_name(index)
        index.zero? ? "Cantrips" : "Spell Slots (#{ActiveSupport::Inflector.ordinalize(index)})"
      end

      def build_known_spells(creature, spells)
        spell_names = (spells.is_a?(Array) ? spells : spells.to_s.split(",")).map { |name| name.to_s.strip }.reject(&:blank?)
        return if spell_names.empty?

        build_descriptors(creature, [ [ "Spells", spell_names.join(", ") ] ])
        spell_names.each do |spell_name|
          spell = name_index_find("spell", spell_name)
          creature.known_spells.create!(spell: spell) if spell
        rescue ActiveRecord::RecordInvalid
          # skip duplicate or invalid known spell
        end
      end

      def build_creature_trait_rules(import_file, creature, record)
        record[:traits].each_with_index do |trait, index|
          rule_record = trait_rule_record(record, trait)
          import_rule(import_file, rule_record)
          # import_rule fills in a unique name when the trait name is blank;
          # look the rule up by the resolved name.
          rule = name_index_find("ability", rule_record[:name])
          creature.linked_rules.create!(rule: rule, sort_order: index) if rule.present?
        end
      end

      def trait_rule_record(record, trait)
        text = [ trait[:text] ]
        text << "Recharge: #{trait[:recharge]}" if trait[:recharge].present?
        text << "Attack: #{trait[:attack]}" if trait[:attack].present?

        {
          type: "ability",
          name: trait[:name],
          source: record[:source],
          text: text.compact.reject(&:blank?)
        }
      end

      def build_ability_scores(entity, record)
        { "Strength" => record[:str], "Dexterity" => record[:dex], "Constitution" => record[:con],
          "Intelligence" => record[:int], "Wisdom" => record[:wis], "Charisma" => record[:cha] }.each do |name, value|
          next if value.blank?

          entity.ability_scores.create!(name: name, base: value.to_i)
        rescue ActiveRecord::RecordInvalid
          # skip if duplicate or validation error
        end
      end

      def build_basic_stats(entity, record)
        ac, ac_note = split_number_and_note(record[:ac])
        entity.defenses.create!(name: "Armor Class", base: ac, description: ac_note) if ac

        hp, hp_note = split_number_and_note(record[:hp])
        entity.trackables.create!(name: "Hit Points", maximum: hp, current: hp, description: hp_note) if hp

        build_movements(entity, record[:speed])
      end

      # Splits a value like "15 (natural armor)" or "59 (7d10+21)" into its
      # leading integer and the remaining note (parentheses stripped), so the
      # AC source / HP formula is preserved instead of being dropped.
      def split_number_and_note(str)
        return [ nil, nil ] if str.blank?

        match = str.to_s.strip.match(/\A(\d+)\s*(.*)\z/)
        return [ nil, nil ] unless match

        note = match[2].strip
        note = note[1..-2].to_s.strip if note.start_with?("(") && note.end_with?(")")
        [ match[1].to_i, note.presence ]
      end

      # Parses a free-text speed string such as "30 ft., fly 60 ft., swim 20 ft."
      # into one Movement per mode (base "Speed", plus Fly/Swim/Climb/Burrow Speed).
      def build_movements(entity, speed_string)
        return if speed_string.blank?

        speed_string.split(",").each do |segment|
          segment = segment.strip
          number = segment[/\d+/]
          next if number.nil?

          keyword = segment[/\A(fly|swim|climb|burrow)\b/i]
          name = keyword ? "#{keyword.downcase.capitalize} Speed" : "Speed"
          entity.movements.create!(name: name, base: number.to_i)
        rescue ActiveRecord::RecordInvalid
          # skip duplicate or invalid movement
        end
      end

      def build_creature_descriptors(creature, record)
        build_descriptors(creature, [
          [ "Size", decode_size(record[:size]) ],
          [ "Type", record[:creature_type] ],
          [ "Alignment", record[:alignment] ],
          [ "Challenge Rating", record[:cr] ],
          [ "Passive Perception", record[:passive]&.to_s ],
          [ "Senses", record[:senses] ],
          [ "Languages", record[:languages] ],
          [ "Immunities", record[:immune] ],
          [ "Resistances", record[:resist] ],
          [ "Vulnerabilities", record[:vulnerable] ],
          [ "Condition Immunities", record[:condition] ],
          [ "Environment", record[:environment] ]
        ])
      end

      # Creates a Descriptor for each non-blank [name, value] pair, skipping
      # duplicates. Shared by creature/character/npc descriptor building.
      def build_descriptors(entity, pairs)
        pairs.each do |name, value|
          next if value.blank?

          entity.descriptors.create!(name: name, description: value.to_s.truncate(255))
        rescue ActiveRecord::RecordInvalid
          # skip duplicate or invalid descriptor
        end
      end

      def build_creature_attacks(creature, actions, default_type)
        return if actions.blank?

        actions.each do |action|
          next if action[:name].blank?

          attack_type = derive_attack_type(action[:text], default_type)
          parsed = Sources::GameMaster5Xml::AttackNotationParser.parse(action[:attack])
          creature.attacks.create!(
            name: action[:name].truncate(64),
            attack_type: attack_type,
            description: action[:text].presence,
            **parse_attack_notation(parsed)
          )
        rescue ActiveRecord::RecordInvalid
          # skip if invalid
        end
      end

      def import_item(import_file, record)
        klass = admin_stock? ? Rulebuilder::StockItem : Rulebuilder::ResidentItem
        name = unique_local_name(record)
        existing = existing_record(klass, name)
        if existing
          return replace_or_skip(import_file, record.merge(name: name), existing) do |item|
            replace_item(item, record)
          end
        end

        category = item_category(record[:item_type])
        item = klass.create!(
          name: name,
          core_rules: CORE_RULES,
          source: record[:source],
          full_description: item_full_description(record),
          weight: record[:weight].presence&.to_d,
          category: (record[:type] == "container" ? "container" : category).presence,
          **privacy_attributes_for(klass).merge(resident_content? ? { resident: resident } : {})
        )
        name_index_add(record[:type], record[:name], item)
        result(import_file, record, "created", item)
      end

      def replace_item(item, record)
        category = item_category(record[:item_type])
        item.update!(
          source: record[:source],
          full_description: item_full_description(record),
          weight: record[:weight].presence&.to_d,
          category: (record[:type] == "container" ? "container" : category).presence,
          **privacy_attributes_for(item.class)
        )
        name_index_add(record[:type], record[:name], item)
      end

      def import_spell(import_file, record)
        klass = admin_stock? ? Rulebuilder::StockSpell : Rulebuilder::ResidentSpell
        name = unique_local_name(record)
        existing = existing_record(klass, name)
        if existing
          return replace_or_skip(import_file, record.merge(name: name), existing) do |spell|
            replace_spell(spell, record)
          end
        end

        spell = klass.create!(
          name: name,
          core_rules: CORE_RULES,
          source: record[:source],
          full_description: record[:text].join("\n").presence,
          school: decode_spell_school(record[:school]),
          casting_time: record[:time].presence,
          components: spell_components_string(record),
          range: record[:range].presence,
          duration: record[:duration].presence,
          levels: spell_levels_list(record),
          tags: record[:ritual] ? [ "ritual" ] : [],
          **privacy_attributes_for(klass).merge(resident_content? ? { resident: resident } : {})
        )
        name_index_add("spell", record[:name], spell)
        result(import_file, record, "created", spell)
      end

      def replace_spell(spell, record)
        spell.update!(
          source: record[:source],
          full_description: record[:text].join("\n").presence,
          school: decode_spell_school(record[:school]),
          casting_time: record[:time].presence,
          components: spell_components_string(record),
          range: record[:range].presence,
          duration: record[:duration].presence,
          levels: spell_levels_list(record),
          tags: record[:ritual] ? [ "ritual" ] : [],
          **privacy_attributes_for(spell.class)
        )
        name_index_add("spell", record[:name], spell)
      end

      def import_rule(import_file, record)
        klass = admin_stock? ? Rulebuilder::StockRule : Rulebuilder::ResidentRule
        name = unique_local_name(record)
        existing = existing_record(klass, name)
        if existing
          return replace_or_skip(import_file, record.merge(name: name), existing) do |rule|
            replace_rule(rule, record)
          end
        end

        full_desc = rule_full_description(record)
        rule = klass.create!(
          name: name,
          core_rules: CORE_RULES,
          source: record[:source],
          full_description: full_desc,
          rule_type: shared_rule_type(record[:type]),
          prerequisites: record[:prerequisite].presence,
          is_shared: true,
          **privacy_attributes_for(klass).merge(resident_content? ? { resident: resident } : {})
        )
        name_index_add(record[:type], record[:name], rule)
        result(import_file, record, "created", rule)
      end

      def replace_rule(rule, record)
        rule.update!(
          source: record[:source],
          full_description: rule_full_description(record),
          rule_type: shared_rule_type(record[:type]),
          prerequisites: record[:prerequisite].presence,
          is_shared: true,
          **privacy_attributes_for(rule.class)
        )
        name_index_add(record[:type], record[:name], rule)
      end

      def shared_rule_type(type)
        return "Species" if type == "race"
        return "Backgrounds" if type == "background"

        type.titleize
      end

      def privacy_attributes_for(klass)
        return {} unless klass.column_names.include?("privacy")

        privacy_value = admin_stock? ? "Residents" : "Private"
        attrs = { privacy: privacy_value }
        attrs[:sheet_privacy] = privacy_value if klass.column_names.include?("sheet_privacy")
        attrs
      end

      def enforce_entity_privacy!(record)
        return unless record.is_a?(Entitybuilder::Entity)

        record.update!(privacy_attributes_for(record.class))
      end

      def existing_record(klass, name)
        scope = klass.where("lower(name) = ?", name.downcase)
        scope = scope.where(core_rules: CORE_RULES) if klass.column_names.include?("core_rules")
        scope = scope.where(resident: resident) if resident_content? && klass.column_names.include?("resident_id")
        scope.first
      end

      def existing_page(adventure, name)
        adventure.pages.where("lower(name) = ? OR slug = ?", name.downcase, name.parameterize).first
      end

      def existing_note(campaign, name)
        campaign.game_master_notes.where("lower(name) = ?", name.downcase).first
      end

      def replace_or_skip(import_file, record, existing, campaign: @import_provenance_campaign)
        unless imported_record?(existing, record, campaign)
          result(import_file, record, "skipped", existing, "already exists")
          return existing
        end

        yield existing
        result(import_file, record, "replaced", existing)
        existing
      end

      def imported_record?(record, import_record, campaign)
        import_result_for_record?(record) || import_provenance_note_for_record?(import_record, campaign)
      end

      def import_result_for_record?(record)
        ImportResult.where(record: record, outcome: %w[created replaced]).exists?
      end

      def import_provenance_note_for_record?(record, campaign)
        return false unless campaign.respond_to?(:game_master_notes)

        campaign.game_master_notes.any? do |note|
          note.full_description.to_s.include?("Game Master 5 XML") &&
            note.full_description.to_s.include?(record[:type].to_s) &&
            note.full_description.to_s.include?(record[:name].to_s)
        end
      end

      def result(import_file, record, outcome, created_record = nil, reason = nil)
        import_result = import_file.import_results.create!(entity_type: record[:type], entity_name: record[:name],
                                                           outcome: outcome, record: created_record, reason: reason)
        track_campaign_import_result(import_result)
        create_import_provenance_note(import_file, import_result)
        import_result
      end

      def with_campaign_import_tracking(provenance_campaign)
        previous_adventures = @campaign_import_adventures
        previous_entities = @campaign_import_entities
        @campaign_import_adventures = []
        @campaign_import_entities = []

        with_import_provenance_campaign(provenance_campaign) do
          yield
        end
      ensure
        @campaign_import_adventures = previous_adventures
        @campaign_import_entities = previous_entities
      end

      def with_import_provenance_campaign(campaign)
        previous_campaign = @import_provenance_campaign
        @import_provenance_campaign = campaign
        yield
      ensure
        @import_provenance_campaign = previous_campaign
      end

      def track_campaign_import_result(import_result)
        return unless import_result.outcome == "created"
        return if @campaign_import_adventures.nil? || @campaign_import_entities.nil?

        @campaign_import_adventures << import_result.record if import_result.record.is_a?(Storybuilder::Adventure)
        @campaign_import_entities << import_result.record if campaign_import_notable_entity?(import_result.record)
      end

      def create_import_provenance_note(import_file, import_result)
        return if @import_provenance_campaign.blank?
        return unless import_result.outcome == "created"
        return if import_result.record.blank?

        note = @import_provenance_campaign.game_master_notes.create!(
          name: import_provenance_note_name(import_result),
          privacy: "Private",
          full_description: import_provenance_note_description(import_file, import_result)
        )
        link_campaign_note_to_entity(note, import_result.record)
      end

      def import_provenance_note_name(import_result)
        I18n.t(
          "importer.provenance_notes.name",
          entity_type: import_result.entity_type,
          entity_name: import_result.entity_name
        ).truncate(55) + " #{import_result.id.first(8)}"
      end

      def import_provenance_note_description(import_file, import_result)
        I18n.t(
          "importer.provenance_notes.description_html",
          created_at: import_provenance_timestamp(import_result),
          entity_type: import_result.entity_type,
          entity_name: import_result.entity_name,
          import_path: import_provenance_path,
          import_label: I18n.t("importer.provenance_notes.import_label"),
          source_file: import_file.file_file_name
        )
      end

      def import_provenance_timestamp(import_result)
        (import_result.record.created_at || import_result.created_at).iso8601
      end

      def import_provenance_path
        "/imports/#{id}"
      end

      def link_campaign_note_to_entity(note, record)
        return unless record.is_a?(Entitybuilder::Entity)

        note.notables.create!(entity: record, name: record.name.truncate(64))
      rescue ActiveRecord::RecordInvalid
        # skip duplicate or invalid note links
      end

      def link_adventure_page_notables(adventure, pages)
        pages.each { |page| link_entities_to_storybuilder_notableable(adventure, page_imported_entities(page)) }
      end

      def link_campaign_page_notables(campaign, pages)
        pages.each { |page| page_imported_entities(page).each { |entity| link_campaign_notable(campaign, entity) } }
      end

      def page_imported_entities(page)
        page.notables.includes(:entity).filter_map(&:entity)
      end

      def link_campaign_notable(campaign, entity)
        return unless entity.is_a?(Entitybuilder::Entity)
        return if campaign.notables.exists?(entity: entity)

        Campaignmanager::Notable.create!(notableable: campaign, entity: entity, name: entity.name.truncate(64))
      rescue ActiveRecord::RecordInvalid
        # skip duplicate or invalid notable links
      end

      def link_entities_to_storybuilder_notableable(notableable, entities)
        existing_entity_ids = notableable.notables.pluck(:entity_id).to_set

        entities.each do |entity|
          next unless entity.is_a?(Entitybuilder::Entity)
          next if existing_entity_ids.include?(entity.id)

          Storybuilder::Notable.create!(notableable: notableable, entity: entity, name: entity.name.truncate(64))
          existing_entity_ids << entity.id
        rescue ActiveRecord::RecordInvalid
          # skip duplicate or invalid notable links
        end
      end

      def campaign_import_notable_entity?(record)
        record.is_a?(Entitybuilder::ResidentCreature) ||
          record.is_a?(Entitybuilder::ResidentNpc) ||
          record.is_a?(Entitybuilder::StockCreature) ||
          record.is_a?(Entitybuilder::StockNpc)
      end

      def finish!
        update!(status: final_status, finished_at: Time.current, summary: import_results.group(:outcome).count)
      end

      def final_status
        return "partial" if import_results.failed.exists?
        return "partial" if import_results.skipped.where.not(reason: "already exists").exists?

        "succeeded"
      end

      def resident_content?
        mode == RESIDENT_CONTENT
      end

      def admin_stock?
        mode == ADMIN_STOCK
      end

      def privacy
        admin_stock? ? "Residents" : "Private"
      end

      def rule_full_description(record)
        parts = []
        parts << "Base class: #{record[:baseclass]}" if record[:baseclass].present?
        parts << "Subclasses: #{record[:subclass_names].join(', ')}" if record[:subclass_names].present?
        abilities = Array(record[:abilities]).reject(&:blank?)
        parts << "Ability score increases: #{abilities.join(', ')}" if abilities.any?
        proficiencies = Array(record[:proficiencies]).reject(&:blank?)
        parts << "Proficiencies: #{proficiencies.join(', ')}" if proficiencies.any?
        parts << "Armor: #{record[:armor]}" if record[:armor].present?
        parts << "Weapons: #{record[:weapons]}" if record[:weapons].present?
        parts << "Tools: #{record[:tools]}" if record[:tools].present?
        parts += record[:traits].map { |t| "**#{t[:name]}**\n#{t[:text]}" } if record[:traits].is_a?(Array)
        text = record[:text]
        parts += Array(text) if text.present?
        parts.compact.reject(&:blank?).join("\n\n").presence
      end

      def item_category(type_code)
        case type_code.to_s.upcase
        when "LA", "MA", "HA", "S" then "armor"
        when "M", "R" then "weapon"
        when "A" then "gear"
        when "W", "WD", "RD", "ST", "RG", "SC" then "wondrous"
        when "P" then "potion"
        when "G", "$" then "gear"
        end
      end

      def item_full_description(record)
        stats = item_stats_block(record)
        text = record[:text].join("\n").presence
        [ stats, text ].compact.join("\n\n").presence
      end

      def item_stats_block(record)
        parts = []
        parts << "**Rarity:** #{record[:detail]}" if record[:detail].present?
        if record[:dmg1].present?
          dmg = record[:dmg2].present? ? "#{record[:dmg1]} / #{record[:dmg2]}" : record[:dmg1]
          parts << "**Damage:** #{dmg} #{record[:dmg_type]}".strip
        end
        parts << "**AC:** #{record[:ac]}" if record[:ac].present?
        parts << "**Range:** #{record[:range]}" if record[:range].present?
        parts << "**Properties:** #{record[:property]}" if record[:property].present?
        parts << "**Strength required:** #{record[:strength]}" if record[:strength].present?
        parts << "**Stealth:** Disadvantage" if record[:stealth].to_s.match?(/yes|1/i)
        parts << "**Value:** #{record[:value]} gp" if record[:value].present?
        parts << "**Magic:** Yes" if record[:magic].to_s.match?(/^[1-9]|yes/i)
        parts.join(" · ").presence
      end

      def decode_size(code)
        { "T" => "Tiny", "S" => "Small", "M" => "Medium",
          "L" => "Large", "H" => "Huge", "G" => "Gargantuan" }[code.to_s.upcase] || code.presence
      end

      def decode_spell_school(code)
        { "A" => "Abjuration", "C" => "Conjuration", "D" => "Divination",
          "EN" => "Enchantment", "EV" => "Evocation", "I" => "Illusion",
          "N" => "Necromancy", "T" => "Transmutation" }[code.to_s.upcase]
      end

      def spell_components_string(record)
        # The common FightClub format stores the whole string in <components>
        # (e.g. "V, S, M (a pinch of sulfur)"); use it verbatim when present.
        return record[:components] if record[:components].present?

        # Fall back to assembling from <v>/<s>/<m> sub-elements.
        parts = []
        parts << "V" if record[:components_v]
        parts << "S" if record[:components_s]
        if record[:components_m]
          parts << (record[:materials].present? ? "M (#{record[:materials]})" : "M")
        end
        parts.join(", ").presence
      end

      def spell_levels_list(record)
        level = record[:level].to_s.strip
        classes = record[:classes].to_s.split(",").map(&:strip).reject(&:blank?)
        return [] if classes.empty?

        classes.map { |c| level.present? ? "#{c} #{level}" : c }
      end

      def parse_leading_number(str)
        return nil if str.blank?

        match = str.match(/\A(\d+)/)
        match ? match[1].to_i : nil
      end

      def derive_attack_type(text, default)
        return "melee" if text.to_s.downcase.include?("melee")
        return "ranged" if text.to_s.downcase.include?("ranged")

        default
      end

      def parse_attack_notation(parsed)
        return {} if parsed.nil?

        result = {}
        if parsed[:bonus].present?
          result[:attack_bonus] = parsed[:bonus].gsub(/[^\d\-]/, "").to_i
        end
        if parsed[:damage].present?
          if (m = parsed[:damage].match(/\A(\d+d\d+)([+\-]\d+)?\z/i))
            result[:damage_dice] = m[1]
            result[:damage_bonus] = m[2].to_i if m[2]
          end
        end
        result
      end

      def clear_entity_import_details(entity)
        entity.descriptors.destroy_all
        entity.ability_scores.destroy_all
        entity.movements.destroy_all
        entity.class_levels.destroy_all
        entity.skills.destroy_all
        entity.trackables.destroy_all
        entity.attacks.destroy_all
        entity.defenses.destroy_all
        entity.saving_throws.destroy_all
        entity.linked_rules.destroy_all
      end

      def name_index_add(kind, name, record)
        @name_index ||= {}
        @name_index[[ kind, name.downcase ]] = record
      end

      def name_index_find(kind, name)
        (@name_index || {})[[ kind, name.downcase ]]
      end

      def local_name(name)
        name.to_s.strip.truncate(LOCAL_NAME_LIMIT, omission: "")
      end

      # Resolves the name to import for a record. Blank names get a unique
      # "No Name N" placeholder (N increments per import run) so that multiple
      # nameless entries are imported as distinct records instead of merging into
      # one. The generated name is written back to record[:name] so dedup,
      # name-index, and result logging all stay consistent.
      def unique_local_name(record)
        name = local_name(record[:name])
        return name if name.present?

        @no_name_counter = @no_name_counter.to_i + 1
        record[:name] = "No Name #{@no_name_counter}"
      end
    end
  end
end
