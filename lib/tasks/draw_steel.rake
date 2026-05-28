namespace :draw_steel do
  namespace :seed do
    SEED_DIR = Rails.root.join("db", "seeds", "draw-steel") unless defined?(SEED_DIR)
    MARKDOWN_OPTIONS = {
      filter_html: true,
      autolink: true,
      space_after_headers: true,
      tables: true,
      safe_links_only: true,
      with_toc_data: true
    }.freeze unless defined?(MARKDOWN_OPTIONS)

    desc "Seed Draw Steel Ancestries"
    task ancestries: :environment do
      seed_rules("ancestries.json")
    end

    desc "Seed Draw Steel Classes"
    task classes: :environment do
      seed_rules("classes.json")
    end

    desc "Seed Draw Steel Kits"
    task kits: :environment do
      seed_rules("kits.json")
    end

    desc "Seed Draw Steel Careers"
    task careers: :environment do
      seed_rules("careers.json")
    end

    desc "Seed Draw Steel Complications"
    task complications: :environment do
      seed_rules("complications.json")
    end

    desc "Seed Draw Steel Conditions"
    task conditions: :environment do
      seed_rules("conditions.json")
    end

    desc "Seed Draw Steel Abilities (StockSpells)"
    task abilities: :environment do
      seed_spells("abilities.json")
    end

    desc "Seed everything for Draw Steel"
    task all: %i[ancestries classes kits careers complications conditions abilities]

    def seed_rules(file)
      records = JSON.parse(File.read(SEED_DIR.join(file)))
      records.each do |attrs|
        rule = Rulebuilder::StockRule.find_or_initialize_by(
          core_rules: attrs["core_rules"],
          rule_type:  attrs["rule_type"],
          name:       attrs["name"]
        )
        rule.assign_attributes(seed_attributes(attrs, [
          "is_shared", "is_3pp", "publisher", "source",
          "short_description", "full_description"
        ]))
        rule.save!
      end
      puts "seeded #{records.size} #{records.first&.dig("rule_type") || "(none)"} records from #{file}"
    end

    def seed_spells(file)
      records = JSON.parse(File.read(SEED_DIR.join(file)))
      records.each do |attrs|
        spell = Rulebuilder::StockSpell.find_or_initialize_by(
          core_rules: attrs["core_rules"],
          name:       attrs["name"]
        )
        spell.assign_attributes(seed_attributes(attrs, [
          "is_3pp", "publisher", "source", "school",
          "casting_time", "components", "range", "target", "duration",
          "short_description", "full_description"
        ]))
        spell.save!
      end
      puts "seeded #{records.size} ability/spell records from #{file}"
    end

    def seed_attributes(attrs, keys)
      attrs.slice(*keys).tap do |seed_attrs|
        seed_attrs["full_description"] = render_markdown(seed_attrs["full_description"])
      end
    end

    def render_markdown(text)
      return text unless text.present?

      markdown_renderer.render(text)
    end

    def markdown_renderer
      @markdown_renderer ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML, MARKDOWN_OPTIONS)
    end
  end
end
