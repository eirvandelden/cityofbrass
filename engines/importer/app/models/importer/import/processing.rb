module Importer
  class Import
    module Processing
      extend ActiveSupport::Concern

      CORE_RULES = "5th Edition"

      def process!
        update!(status: "running", started_at: Time.current)
        prepare_files_from_preview! if import_files.empty?
        ordered_import_files.each { |import_file| process_import_file(import_file) }
        finish!
      rescue StandardError => error
        update!(status: "failed", finished_at: Time.current, summary: { "error" => error.message })
      end

      def prepare_files_from_preview!
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

      def process_import_file(import_file)
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

        unsupported_import_file(import_file)
      end

      def import_compendium(import_file, document)
        document.compendium_records.each { |record| import_compendium_record(import_file, record) }
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
        klass = compendium_class_for(record[:type])
        existing = existing_record(klass, record[:name])
        return result(import_file, record, "skipped", existing, "already exists") if existing

        result(import_file, record, "created", create_record!(klass, record))
      end

      def import_campaign(import_file, document)
        campaign = document.campaign_record
        return if campaign.blank?

        root = import_campaign_root(import_file, campaign)
        campaign[:adventures].each { |adventure| import_adventure(import_file, adventure, root) }
        campaign[:notes].each { |note| import_note(import_file, note, root) }
        campaign[:pcs].each { |pc| import_pc(import_file, pc) }
        campaign[:npcs].each { |npc| import_npc(import_file, npc) }
      end

      def import_campaign_root(import_file, campaign)
        return resident_campaign(import_file, campaign) if resident_content?

        first_adventure = campaign[:adventures].first || { name: campaign[:name] }
        stock_adventure(import_file, first_adventure)
      end

      def resident_campaign(import_file, campaign)
        record = Campaignmanager::Campaign.create!(resident: resident, name: campaign[:name], privacy: "Private",
                                                   core_rules: CORE_RULES)
        result(import_file, { type: "campaign", name: campaign[:name] }, "created", record)
        record
      end

      def stock_adventure(import_file, adventure)
        record = Storybuilder::StockAdventure.create!(name: adventure[:name], privacy: "Residents", core_rules: CORE_RULES)
        result(import_file, adventure.merge(type: "adventure"), "created", record)
        record
      end

      def import_adventure(import_file, adventure, root)
        record = resident_content? ? resident_adventure(import_file, adventure, root) : root
        adventure[:encounters].each { |encounter| import_encounter(import_file, encounter, record) }
      end

      def resident_adventure(import_file, adventure, campaign)
        record = Storybuilder::ResidentAdventure.create!(resident: resident, name: adventure[:name], privacy: "Private",
                                                         core_rules: CORE_RULES)
        campaign.update!(adventure: record)
        result(import_file, adventure, "created", record)
        record
      end

      def import_encounter(import_file, encounter, adventure)
        record = Storybuilder::Page.create!(adventure: adventure, name: encounter[:name], privacy: privacy)
        result(import_file, encounter, "created", record)
      end

      def import_note(import_file, note, root)
        return import_stock_note(import_file, note, root) if admin_stock?

        record = Campaignmanager::GameMasterNote.create!(campaign: root, name: note[:name], privacy: "Private")
        result(import_file, note, "created", record)
      end

      def import_stock_note(import_file, note, adventure)
        record = Storybuilder::Page.create!(adventure: adventure, name: note[:name], privacy: "Residents", tags: [ "note" ])
        result(import_file, note, "created", record)
      end

      def import_pc(import_file, pc)
        return result(import_file, pc, "skipped", nil, "no stock character target") if admin_stock?

        record = Entitybuilder::ResidentCharacter.create!(resident: resident, name: pc[:name], core_rules: CORE_RULES)
        enforce_entity_privacy!(record)
        result(import_file, pc, "created", record)
      end

      def import_npc(import_file, npc)
        klass = admin_stock? ? Entitybuilder::StockNpc : Entitybuilder::ResidentNpc
        result(import_file, npc, "created", create_record!(klass, npc))
      end

      def create_record!(klass, record)
        klass.create!(attributes_for(record, klass)).tap { |created_record| enforce_entity_privacy!(created_record) }
      end

      def compendium_class_for(type)
        return admin_stock? ? Entitybuilder::StockCreature : Entitybuilder::ResidentCreature if type == "monster"
        return admin_stock? ? Rulebuilder::StockItem : Rulebuilder::ResidentItem if type == "item"
        return admin_stock? ? Rulebuilder::StockSpell : Rulebuilder::ResidentSpell if type == "spell"

        admin_stock? ? Rulebuilder::StockRule : Rulebuilder::ResidentRule
      end

      def attributes_for(record, klass)
        base_attributes(record, klass).merge(type_attributes(record))
      end

      def base_attributes(record, klass)
        attributes = { name: record[:name], core_rules: CORE_RULES, source: record[:source], full_description: record[:description] }
        attributes[:resident] = resident if resident_content? && klass.column_names.include?("resident_id")
        attributes.merge(privacy_attributes_for(klass))
      end

      def type_attributes(record)
        return { rule_type: record[:type].titleize, is_shared: true } if %w[race background feat class].include?(record[:type])
        return { category: "container" } if record[:type] == "item"

        {}
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
        scope = scope.where(resident: resident) if resident_content? && klass.column_names.include?("resident_id")
        scope.first
      end

      def result(import_file, record, outcome, created_record = nil, reason = nil)
        import_file.import_results.create!(entity_type: record[:type], entity_name: record[:name], outcome: outcome,
                                           record: created_record, reason: reason)
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
    end
  end
end
