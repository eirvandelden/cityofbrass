namespace :fifth_edition do
  namespace :seed do
    FIFTH_SEED_DIR = Rails.root.join("db", "seeds", "5th-edition") unless defined?(FIFTH_SEED_DIR)
    FIFTH_MARKDOWN_OPTIONS = {
      filter_html: true,
      autolink: true,
      space_after_headers: true,
      tables: true,
      safe_links_only: true,
      with_toc_data: true
    }.freeze unless defined?(FIFTH_MARKDOWN_OPTIONS)
    FIFTH_CREATURE_COLLECTIONS = {
      ability_scores: %w[name base modifier],
      descriptors: %w[name description],
      movements: %w[name base ability_score description],
      trackables: %w[name maximum current],
      saving_throws: %w[name base ability_score],
      skills: %w[name bonus ability_score],
      attacks: %w[name attack_type attack_range attack_bonus damage_dice damage_bonus damage_type description]
    }.freeze unless defined?(FIFTH_CREATURE_COLLECTIONS)

    desc "Seed 5th Edition Classes"
    task classes: :environment do
      fifth_seed_rules("classes.json")
    end

    desc "Seed 5th Edition Subclasses"
    task subclasses: :environment do
      fifth_seed_rules("subclasses.json")
    end

    desc "Seed 5th Edition Species"
    task species: :environment do
      fifth_seed_rules("species.json")
    end

    desc "Seed 5th Edition Backgrounds"
    task backgrounds: :environment do
      fifth_seed_rules("backgrounds.json")
    end

    desc "Seed 5th Edition Feats"
    task feats: :environment do
      fifth_seed_rules("feats.json")
    end

    desc "Seed 5th Edition Conditions"
    task conditions: :environment do
      fifth_seed_rules("conditions.json")
    end

    desc "Seed 5th Edition Rule References"
    task rule_references: :environment do
      fifth_seed_rules("rule_references.json")
    end

    desc "Seed 5th Edition Spells (StockSpells)"
    task spells: :environment do
      fifth_seed_spells("spells.json")
    end

    desc "Seed 5th Edition Items (StockItems)"
    task items: :environment do
      fifth_seed_items("items.json")
    end

    desc "Seed 5th Edition Monsters (StockCreatures)"
    task creatures: :environment do
      fifth_seed_creatures("creatures.json")
    end

    desc "Seed 5th Edition Animals (StockCreatures)"
    task animals: :environment do
      fifth_seed_creatures("animals.json")
    end

    desc "Seed everything for 5th Edition"
    task all: %i[classes subclasses species backgrounds feats conditions rule_references spells items creatures animals]

    def fifth_seed_rules(file)
      records = JSON.parse(File.read(FIFTH_SEED_DIR.join(file)))
      records.each do |attrs|
        rule = Rulebuilder::StockRule.find_or_initialize_by(
          core_rules: attrs["core_rules"],
          rule_type:  attrs["rule_type"],
          name:       attrs["name"]
        ) { |new_rule| new_rule.id = SecureRandom.uuid }
        rule.assign_attributes(fifth_seed_rule_attributes(attrs))
        rule.save!
      end
      puts "seeded #{records.size} #{records.first&.dig("rule_type") || "(none)"} records from #{file}"
    end

    def fifth_seed_spells(file)
      records = JSON.parse(File.read(FIFTH_SEED_DIR.join(file)))
      records.each do |attrs|
        spell = Rulebuilder::StockSpell.find_or_initialize_by(
          core_rules: attrs["core_rules"],
          name:       attrs["name"],
          school:     attrs["school"]
        ) { |new_spell| new_spell.id = SecureRandom.uuid }
        spell.assign_attributes(fifth_seed_spell_attributes(attrs))
        spell.save!
      end
      puts "seeded #{records.size} spell records from #{file}"
    end

    def fifth_seed_items(file)
      records = JSON.parse(File.read(FIFTH_SEED_DIR.join(file)))
      records.each do |attrs|
        item = Rulebuilder::StockItem.find_or_initialize_by(
          core_rules: attrs["core_rules"],
          name:       attrs["name"]
        ) { |new_item| new_item.id = SecureRandom.uuid }
        item.assign_attributes(
          attrs.slice("is_3pp", "publisher", "source", "category",
                      "short_description").tap do |a|
            a["full_description"] = fifth_render_markdown(attrs["full_description"])
          end
        )
        item.save!
      end
      puts "seeded #{records.size} item records from #{file}"
    end

    def fifth_seed_creatures(file)
      records = JSON.parse(File.read(FIFTH_SEED_DIR.join(file)))
      records.each do |attrs|
        creature = Entitybuilder::StockCreature.find_or_initialize_by(
          core_rules: attrs["core_rules"],
          name:       attrs["name"]
        ) { |c| c.id = SecureRandom.uuid }
        creature.assign_attributes(fifth_seed_creature_attributes(attrs))
        fifth_replace_creature_children(creature, attrs)
        creature.save!
      end
      puts "seeded #{records.size} creature records from #{file}"
    end

    def fifth_seed_rule_attributes(attrs)
      attrs.slice("is_shared", "is_3pp", "publisher", "source",
                  "short_description", "full_description").tap do |a|
        a["full_description"] = fifth_render_markdown(a["full_description"])
      end
    end

    def fifth_seed_spell_attributes(attrs)
      attrs.slice("is_3pp", "publisher", "source", "school",
                  "casting_time", "components", "range", "target", "duration",
                  "short_description", "full_description").tap do |a|
        a["full_description"] = fifth_render_markdown(a["full_description"])
      end
    end

    def fifth_seed_creature_attributes(attrs)
      {
        publisher:         attrs["publisher"],
        source:            attrs["source"],
        short_description: attrs["short_description"],
        full_description:  fifth_render_markdown(attrs["full_description"])
      }
    end

    def fifth_replace_creature_children(creature, attrs)
      FIFTH_CREATURE_COLLECTIONS.each do |association_name, keys|
        association = creature.public_send(association_name)
        association.destroy_all if creature.persisted?
        association.reset

        Array(attrs[association_name.to_s]).each_with_index do |record, index|
          association.build(record.slice(*keys).merge("sort_order" => index))
        end
      end
    end

    def fifth_render_markdown(text)
      return text unless text.present?

      fifth_markdown_renderer.render(text)
    end

    def fifth_markdown_renderer
      @fifth_markdown_renderer ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML, FIFTH_MARKDOWN_OPTIONS)
    end
  end
end
