module Importer
  class Import
    module Processing
      extend ActiveSupport::Concern

      CORE_RULES = "5th Edition"

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
        document.compendium_records.each { |record| import_compendium_record(import_file, record) }
      end

      def process_character_file(import_file, document)
        document.character_records.each { |record| import_character_record(import_file, record) }
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
        when "race", "background", "feat", "class" then import_rule(import_file, record)
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
          campaign[:adventures].each { |adventure| import_adventure(import_file, adventure, root) }
          campaign[:notes].each { |note| import_note(import_file, note, root) }
          campaign[:pcs].each { |pc| import_pc(import_file, pc) }
          campaign[:npcs].each { |npc| import_npc(import_file, npc) }
        end
      end

      def import_stock_campaign(import_file, campaign)
        with_campaign_import_tracking(nil) do
          import_campaign_monsters(import_file, campaign)
          import_campaign_items(import_file, campaign)
          adventures = campaign[:adventures].map { |adventure| import_stock_adventure(import_file, adventure) }
          root = adventures.first || stock_adventure(import_file, { name: campaign_name(import_file, campaign) })

          campaign[:notes].each { |note| import_stock_note(import_file, note, root) }
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

      def resident_campaign(import_file, campaign)
        name = campaign_name(import_file, campaign)
        existing = existing_record(Campaignmanager::Campaign, name)
        if existing
          result(import_file, { type: "campaign", name: name }, "skipped", existing, "already exists")
          return existing
        end

        record = Campaignmanager::Campaign.create!(resident: resident, name: name, privacy: "Private", core_rules: CORE_RULES)
        with_import_provenance_campaign(record) do
          result(import_file, { type: "campaign", name: name }, "created", record)
        end
        record
      end

      def campaign_name(import_file, campaign)
        campaign[:name].presence || File.basename(import_file.file_file_name.to_s, ".*").tr("_-", " ")
      end

      def stock_adventure(import_file, adventure)
        existing = existing_record(Storybuilder::StockAdventure, adventure[:name])
        if existing
          result(import_file, adventure.merge(type: "adventure"), "skipped", existing, "already exists")
          return existing
        end

        record = Storybuilder::StockAdventure.create!(name: adventure[:name], privacy: "Residents", core_rules: CORE_RULES)
        result(import_file, adventure.merge(type: "adventure"), "created", record)
        record
      end

      def import_stock_adventure(import_file, adventure)
        record = stock_adventure(import_file, adventure)
        adventure[:encounters].each { |encounter| import_encounter(import_file, encounter, record) }
        record
      end

      def import_adventure(import_file, adventure, root)
        record = resident_adventure(import_file, adventure, root)
        adventure[:encounters].each { |encounter| import_encounter(import_file, encounter, record) }
      end

      def resident_adventure(import_file, adventure, campaign)
        existing = existing_record(Storybuilder::ResidentAdventure, adventure[:name])
        if existing
          campaign.update!(adventure: existing) if campaign.adventure.blank?
          result(import_file, adventure, "skipped", existing, "already exists")
          return existing
        end

        record = Storybuilder::ResidentAdventure.create!(resident: resident, name: adventure[:name], privacy: "Private",
                                                         core_rules: CORE_RULES)
        campaign.update!(adventure: record) if campaign.adventure.blank?
        result(import_file, adventure, "created", record)
        record
      end

      def import_encounter(import_file, encounter, adventure)
        existing = existing_page(adventure, encounter[:name])
        return result(import_file, encounter, "skipped", existing, "already exists") if existing

        record = Storybuilder::Page.create!(
          adventure: adventure,
          name: encounter[:name],
          privacy: privacy,
          full_description: encounter[:description].presence
        )
        link_encounter_combatants(record, encounter[:combatants])
        result(import_file, encounter, "created", record)
      end

      def link_encounter_combatants(page, combatants)
        return if combatants.blank?

        creature_class = admin_stock? ? Entitybuilder::StockCreature : Entitybuilder::ResidentCreature
        existing_entity_ids = page.notables.pluck(:entity_id).to_set

        combatants.each do |combatant|
          next if combatant[:name].blank?

          creature = name_index_find("monster", combatant[:name]) ||
                     existing_record(creature_class, combatant[:name])
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

        existing = existing_note(root, note[:name])
        return result(import_file, note, "skipped", existing, "already exists") if existing

        record = Campaignmanager::GameMasterNote.create!(
          campaign: root,
          name: note[:name],
          privacy: "Private",
          full_description: note[:description].presence
        )
        result(import_file, note, "created", record)
      end

      def import_stock_note(import_file, note, adventure)
        existing = existing_page(adventure, note[:name])
        return result(import_file, note, "skipped", existing, "already exists") if existing

        record = Storybuilder::Page.create!(
          adventure: adventure,
          name: note[:name],
          privacy: "Residents",
          tags: [ "note" ],
          full_description: note[:description].presence
        )
        result(import_file, note, "created", record)
      end

      def import_pc(import_file, pc)
        return result(import_file, pc, "skipped", nil, "no stock character target") if admin_stock?

        existing = existing_record(Entitybuilder::ResidentCharacter, pc[:name])
        if existing
          existing.update!(full_description: pc[:description]) if pc[:description].present? && existing.full_description.blank?
          return result(import_file, pc, "skipped", existing, "already exists")
        end

        record = Entitybuilder::ResidentCharacter.create!(
          resident: resident,
          name: pc[:name],
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
        return if label.blank?

        existing = name_index_find("pc", label) || existing_record(Entitybuilder::ResidentCharacter, label)

        if existing
          merge_character_stats(existing, pc)
          return result(import_file, pc, "skipped", existing, "already exists")
        end

        character = Entitybuilder::ResidentCharacter.create!(
          resident: resident,
          name: label.truncate(255),
          core_rules: CORE_RULES,
          full_description: pc[:description].presence
        )
        enforce_entity_privacy!(character)
        build_character_associations(character, pc)
        name_index_add("pc", label, character)
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

      def build_character_associations(character, pc)
        build_ability_scores(character, pc)
        build_basic_stats(character, pc)
        build_character_name_info(character, pc)
        build_saves_and_skills(character, pc)
        build_creature_attacks(character, pc[:actions], "melee")
      end

      def build_character_name_info(character, pc)
        if pc[:size].present?
          begin
            character.descriptors.create!(name: "Size", description: pc[:size].truncate(255))
          rescue ActiveRecord::RecordInvalid
            # skip if duplicate or validation error
          end
        end

        parsed_name = Sources::GameMaster5Xml::PcNameParser.parse(pc[:name])
        return unless parsed_name

        begin
          character.class_levels.create!(name: parsed_name[:class_name], level: parsed_name[:level])
        rescue ActiveRecord::RecordInvalid
          # skip if duplicate or validation error
        end
      end

      def build_saves_and_skills(character, pc)
        pc[:saves].each do |save_str|
          next unless (m = save_str.match(/\A(.+?)\s+([+\-]\d+)\z/))

          character.saving_throws.create!(name: m[1].strip, base: m[2].to_i)
        rescue ActiveRecord::RecordInvalid
          # skip if duplicate or validation error
        end

        pc[:skills].each do |skill_str|
          next unless (m = skill_str.match(/\A(.+?)\s+([+\-]\d+)\z/))

          character.skills.create!(name: m[1].strip, bonus: m[2].to_i)
        rescue ActiveRecord::RecordInvalid
          # skip if duplicate or validation error
        end
      end

      def import_npc(import_file, npc)
        klass = admin_stock? ? Entitybuilder::StockNpc : Entitybuilder::ResidentNpc
        existing = existing_record(klass, npc[:name])
        return result(import_file, npc, "skipped", existing, "already exists") if existing

        entity = klass.create!(
          name: npc[:name],
          core_rules: CORE_RULES,
          source: npc[:source],
          full_description: npc[:description].presence,
          **privacy_attributes_for(klass).merge(resident_content? ? { resident: resident } : {})
        )
        enforce_entity_privacy!(entity)

        [ [ "Size", npc[:size] ], [ "Type", npc[:npc_type] ], [ "Alignment", npc[:alignment] ] ].each do |name, val|
          entity.descriptors.create!(name: name, description: val.to_s.truncate(255)) if val.present?
        rescue ActiveRecord::RecordInvalid
          # skip if duplicate or validation error
        end

        if (ac = parse_leading_number(npc[:ac]))
          begin
            entity.defenses.create!(name: "Armor Class", base: ac)
          rescue ActiveRecord::RecordInvalid
            # skip if duplicate or validation error
          end
        end

        if (hp = parse_leading_number(npc[:hp]))
          entity.trackables.create!(name: "Hit Points", maximum: hp, current: hp) rescue nil
        end

        result(import_file, npc, "created", entity)
      end

      def import_monster(import_file, record)
        klass = admin_stock? ? Entitybuilder::StockCreature : Entitybuilder::ResidentCreature
        existing = existing_record(klass, record[:name])
        if existing
          name_index_add("monster", record[:name], existing)
          return result(import_file, record, "skipped", existing, "already exists")
        end

        traits_text = record[:traits].map { |t| "**#{t[:name]}**\n#{t[:text]}" }.join("\n\n")
        creature = klass.create!(
          name: record[:name],
          core_rules: CORE_RULES,
          source: record[:source],
          short_description: record[:cr].presence,
          full_description: traits_text.presence,
          **privacy_attributes_for(klass).merge(resident_content? ? { resident: resident } : {})
        )
        enforce_entity_privacy!(creature)
        build_creature_associations(creature, record)
        name_index_add("monster", record[:name], creature)
        result(import_file, record, "created", creature)
      end

      def build_creature_associations(creature, record)
        build_ability_scores(creature, record)
        build_basic_stats(creature, record)
        build_creature_descriptors(creature, record)
        build_creature_attacks(creature, record[:actions], "melee")
        build_creature_attacks(creature, record[:reactions], "melee")
        build_creature_attacks(creature, record[:legendary], "melee")
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
        if (ac = parse_leading_number(record[:ac]))
          entity.defenses.create!(name: "Armor Class", base: ac)
        end
        if (hp = parse_leading_number(record[:hp]))
          entity.trackables.create!(name: "Hit Points", maximum: hp, current: hp)
        end
        if (speed = parse_leading_number(record[:speed]))
          entity.movements.create!(name: "Speed", base: speed)
        end
      end

      def build_creature_descriptors(creature, record)
        [
          [ "Size", record[:size] ],
          [ "Type", record[:creature_type] ],
          [ "Senses", record[:senses] ],
          [ "Languages", record[:languages] ],
          [ "Immunities", record[:immune] ],
          [ "Resistances", record[:resist] ],
          [ "Vulnerabilities", record[:vulnerable] ],
          [ "Condition Immunities", record[:condition] ]
        ].each do |name, value|
          next if value.blank?

          creature.descriptors.create!(name: name, description: value.truncate(255))
        rescue ActiveRecord::RecordInvalid
          # skip if duplicate
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
            description: action[:text].presence&.truncate(6000),
            **parse_attack_notation(parsed)
          )
        rescue ActiveRecord::RecordInvalid
          # skip if invalid
        end
      end

      def import_item(import_file, record)
        klass = admin_stock? ? Rulebuilder::StockItem : Rulebuilder::ResidentItem
        existing = existing_record(klass, record[:name])
        return result(import_file, record, "skipped", existing, "already exists") if existing

        full_desc = record[:text].join("\n").presence
        category = item_category(record[:item_type])
        item = klass.create!(
          name: record[:name],
          core_rules: CORE_RULES,
          source: record[:source],
          full_description: full_desc,
          category: (record[:type] == "container" ? "container" : category).presence,
          **privacy_attributes_for(klass).merge(resident_content? ? { resident: resident } : {})
        )
        name_index_add(record[:type], record[:name], item)
        result(import_file, record, "created", item)
      end

      def import_spell(import_file, record)
        klass = admin_stock? ? Rulebuilder::StockSpell : Rulebuilder::ResidentSpell
        existing = existing_record(klass, record[:name])
        return result(import_file, record, "skipped", existing, "already exists") if existing

        full_desc = record[:text].join("\n").presence
        spell = klass.create!(
          name: record[:name],
          core_rules: CORE_RULES,
          source: record[:source],
          full_description: full_desc,
          **privacy_attributes_for(klass).merge(resident_content? ? { resident: resident } : {})
        )
        name_index_add("spell", record[:name], spell)
        result(import_file, record, "created", spell)
      end

      def import_rule(import_file, record)
        klass = admin_stock? ? Rulebuilder::StockRule : Rulebuilder::ResidentRule
        existing = existing_record(klass, record[:name])
        return result(import_file, record, "skipped", existing, "already exists") if existing

        full_desc = rule_full_description(record)
        rule = klass.create!(
          name: record[:name],
          core_rules: CORE_RULES,
          source: record[:source],
          full_description: full_desc,
          rule_type: shared_rule_type(record[:type]),
          is_shared: true,
          **privacy_attributes_for(klass).merge(resident_content? ? { resident: resident } : {})
        )
        name_index_add(record[:type], record[:name], rule)
        result(import_file, record, "created", rule)
      end

      def shared_rule_type(type)
        return "Species" if type == "race"
        return "Backgrounds" if type == "background"

        type.titleize
      end

      def privacy_attributes_for(klass)
        return {} unless klass.column_names.include?("privacy")
        return { privacy: "Residents", sheet_privacy: "Residents" } if admin_stock?

        { privacy: "Private", sheet_privacy: "Private" }
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
        adventure.pages.where("lower(name) = ?", name.downcase).first
      end

      def existing_note(campaign, name)
        campaign.game_master_notes.where("lower(name) = ?", name.downcase).first
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
          link_created_entities_to_campaign_adventures
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

      def link_created_entities_to_campaign_adventures
        return if @campaign_import_adventures.blank? || @campaign_import_entities.blank?

        @campaign_import_adventures.each do |adventure|
          link_entities_to_storybuilder_notableable(adventure, @campaign_import_entities)
        end
      end

      def link_entities_to_storybuilder_notableable(notableable, entities)
        existing_entity_ids = notableable.notables.pluck(:entity_id).to_set

        entities.each do |entity|
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
        parts += record[:traits].map { |t| "**#{t[:name]}**\n#{t[:text]}" } if record[:traits].is_a?(Array)
        text = record[:text]
        parts += Array(text) if text.present?
        parts.compact.reject(&:blank?).join("\n\n").presence
      end

      def item_category(type_code)
        case type_code.to_s.upcase
        when "M" then "weapon"
        when "A" then "armor"
        when "S" then "shield"
        when "W", "WD", "RD", "SC" then "wondrous"
        when "P" then "potion"
        when "G" then "gear"
        end
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

      def name_index_add(kind, name, record)
        @name_index ||= {}
        @name_index[[ kind, name.downcase ]] = record
      end

      def name_index_find(kind, name)
        (@name_index || {})[[ kind, name.downcase ]]
      end
    end
  end
end
