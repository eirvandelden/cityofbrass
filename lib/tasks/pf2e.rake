namespace :db do
  namespace :seed do
    namespace :pf2e do
      PF2E_SEED_DIR = Rails.root.join("db", "seeds", "pf2e")

      # ── Rules ──────────────────────────────────────────────────────────

      desc "Seed PF2e Ancestries"
      task ancestries: :environment do
        CoreRules::Seeder.seed_rules(PF2E_SEED_DIR, "ancestries.json")
      end

      desc "Seed PF2e Heritages"
      task heritages: :environment do
        CoreRules::Seeder.seed_rules(PF2E_SEED_DIR, "heritages.json")
      end

      desc "Seed PF2e Backgrounds"
      task backgrounds: :environment do
        CoreRules::Seeder.seed_rules(PF2E_SEED_DIR, "backgrounds.json")
      end

      desc "Seed PF2e Classes"
      task classes: :environment do
        CoreRules::Seeder.seed_rules(PF2E_SEED_DIR, "classes.json")
      end

      desc "Seed PF2e Ancestry Feats"
      task ancestry_feats: :environment do
        CoreRules::Seeder.seed_rules(PF2E_SEED_DIR, "ancestry-feats.json")
      end

      desc "Seed PF2e Class Feats"
      task class_feats: :environment do
        CoreRules::Seeder.seed_rules(PF2E_SEED_DIR, "class-feats.json")
      end

      desc "Seed PF2e General Feats"
      task general_feats: :environment do
        CoreRules::Seeder.seed_rules(PF2E_SEED_DIR, "general-feats.json")
      end

      desc "Seed PF2e Skill Feats"
      task skill_feats: :environment do
        CoreRules::Seeder.seed_rules(PF2E_SEED_DIR, "skill-feats.json")
      end

      desc "Seed PF2e Conditions"
      task conditions: :environment do
        CoreRules::Seeder.seed_rules(PF2E_SEED_DIR, "conditions.json")
      end

      desc "Seed PF2e Deities"
      task deities: :environment do
        CoreRules::Seeder.seed_rules(PF2E_SEED_DIR, "deities.json")
      end

      # ── Spells ─────────────────────────────────────────────────────────

      desc "Seed PF2e Spells (one record per spell+tradition)"
      task spells: :environment do
        CoreRules::Seeder.seed_spells(PF2E_SEED_DIR, "spells.json")
      end

      # ── Items ──────────────────────────────────────────────────────────

      desc "Seed PF2e Weapons"
      task weapons: :environment do
        seed_items("weapons.json")
      end

      desc "Seed PF2e Armor"
      task armor: :environment do
        seed_items("armor.json")
      end

      desc "Seed PF2e Gear"
      task gear: :environment do
        seed_items("gear.json")
      end

      # ── Creatures ──────────────────────────────────────────────────────

      desc "Seed PF2e Bestiary creatures (StockCreature)"
      task creatures: :environment do
        seed_creatures("creatures.json")
      end

      # ── All ────────────────────────────────────────────────────────────

      desc "Seed all PF2e content. Each sub-task is independently re-runnable."
      task all: %i[ancestries heritages backgrounds classes
                   ancestry_feats class_feats general_feats skill_feats
                   conditions deities spells weapons armor gear creatures]

      # ── Helpers ────────────────────────────────────────────────────────

      def seed_items(file)
        records = JSON.parse(File.read(PF2E_SEED_DIR.join(file)))
        records.each do |attrs|
          item = Rulebuilder::StockItem.find_or_initialize_by(
            core_rules: attrs["core_rules"],
            name:       attrs["name"],
            category:   attrs["category"]
          ) { |i| i.id = SecureRandom.uuid }
          item.assign_attributes(attrs.slice(
            "is_3pp", "publisher", "source", "category",
            "short_description", "full_description", "tags"
          ))
          item.full_description = CoreRules::Seeder.render_markdown(item.full_description)
          item.save!
        end
        puts "seeded #{records.size} #{records.first&.dig("category") || "(none)"} records from #{file}"
      end

      def seed_creatures(file)
        records = JSON.parse(File.read(PF2E_SEED_DIR.join(file)))
        records.each do |attrs|
          creature = Entitybuilder::StockCreature.find_or_initialize_by(
            name:       attrs["name"],
            core_rules: attrs["core_rules"]
          ) { |c| c.id = SecureRandom.uuid }

          creature.assign_attributes(attrs.slice(
            "short_description", "full_description", "publisher", "source", "is_3pp"
          ))
          creature.full_description = CoreRules::Seeder.render_markdown(creature.full_description)
          creature.save!

          creature.ability_scores.delete_all
          creature.trackables.delete_all
          creature.base_values.delete_all
          creature.defenses.delete_all
          creature.saving_throws.delete_all
          creature.attacks.delete_all

          Array(attrs["ability_scores"]).each_with_index do |as_attrs, index|
            creature.ability_scores.build(
              name:       as_attrs["name"],
              base:       as_attrs["base"].to_i,
              modifier:   as_attrs["modifier"].to_i,
              dice:       as_attrs["dice"].presence,
              sort_order: index
            )
          end

          Array(attrs["trackables"]).each_with_index do |t_attrs, index|
            creature.trackables.build(
              name:       t_attrs["name"],
              maximum:    t_attrs["maximum"].to_i,
              current:    t_attrs["current"].to_i,
              sort_order: index
            )
          end

          Array(attrs["base_values"]).each_with_index do |bv_attrs, index|
            creature.base_values.build(
              name:       bv_attrs["name"],
              value:      bv_attrs["value"].to_i,
              dice:       bv_attrs["dice"].presence,
              sort_order: index
            )
          end

          Array(attrs["defenses"]).each_with_index do |d_attrs, index|
            creature.defenses.build(
              name:          d_attrs["name"],
              base:          d_attrs["base"].to_i,
              ability_score: d_attrs["ability_score"],
              sort_order:    index
            )
          end

          Array(attrs["saving_throws"]).each_with_index do |st_attrs, index|
            creature.saving_throws.build(
              name:          st_attrs["name"],
              base:          st_attrs["base"].to_i,
              ability_score: st_attrs["ability_score"],
              sort_order:    index
            )
          end

          Array(attrs["attacks"]).each_with_index do |atk_attrs, index|
            creature.attacks.build(
              name:                 atk_attrs["name"],
              attack_type:          atk_attrs["attack_type"] == "Ranged" ? "Range" : atk_attrs["attack_type"],
              attack_ability_score: atk_attrs["attack_ability_score"],
              description:          atk_attrs["description"],
              sort_order:           index
            )
          end

          creature.save!
        end
        puts "seeded #{records.size} creature records from #{file}"
      end
    end
  end
end
