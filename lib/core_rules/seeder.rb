module CoreRules
  module Seeder
    module_function

    MARKDOWN_OPTIONS = {
      filter_html: true,
      autolink: true,
      space_after_headers: true,
      tables: true,
      safe_links_only: true,
      with_toc_data: true
    }.freeze

    def seed_rules(seed_dir, file)
      records = JSON.parse(File.read(seed_dir.join(file)))
      records.each do |attrs|
        rule = Rulebuilder::StockRule.find_or_initialize_by(
          core_rules: attrs["core_rules"],
          rule_type:  attrs["rule_type"],
          name:       attrs["name"]
        ) { |new_rule| new_rule.id = SecureRandom.uuid }
        rule.assign_attributes(seed_attributes(attrs, [
          "is_shared", "is_3pp", "publisher", "source",
          "short_description", "full_description"
        ]))
        rule.save!
      end
      puts "seeded #{records.size} #{records.first&.dig("rule_type") || "(none)"} records from #{file}"
    end

    def seed_spells(seed_dir, file)
      records = JSON.parse(File.read(seed_dir.join(file)))
      records.each do |attrs|
        spell = Rulebuilder::StockSpell.find_or_initialize_by(
          core_rules: attrs["core_rules"],
          name:       attrs["name"],
          school:     attrs["school"]
        ) { |new_spell| new_spell.id = SecureRandom.uuid }
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
      return text if html_fragment?(text)

      markdown_renderer.render(text)
    end

    def markdown_renderer
      Redcarpet::Markdown.new(Redcarpet::Render::HTML, MARKDOWN_OPTIONS)
    end

    def html_fragment?(text)
      text.match?(%r{</?[a-z][^>]*>}i)
    end
  end
end
