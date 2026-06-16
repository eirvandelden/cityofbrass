class ConvertCoreRulesDisplayNamesToSlugs < ActiveRecord::Migration[6.1]
  TABLES = %w[
    campaignmanager_campaigns
    entitybuilder_entities
    rulebuilder_abilities
    rulebuilder_feats
    rulebuilder_items
    rulebuilder_rules
    rulebuilder_spells
    storybuilder_adventures
  ].freeze

  DISPLAY_NAME_TO_SLUG = {
    "PFRPG"         => "pf1e",
    "Pathfinder 2e" => "pf2e",
    "3.5 Edition"   => "dnd35e",
    "4th Edition"   => "dnd4e",
    "5th Edition"   => "dnd5e",
    "d20 Future"    => "d20Future",
    "d20 Modern"    => "d20Modern",
    "Draw Steel"    => "drawSteel",
    "Fate Core"     => "fateCore",
    "Generic"       => "generic",
    "W.O.I.N"      => "woin"
  }.freeze

  SLUG_TO_DISPLAY_NAME = DISPLAY_NAME_TO_SLUG.invert.freeze

  def up
    TABLES.each do |table|
      DISPLAY_NAME_TO_SLUG.each do |display_name, slug|
        execute <<~SQL
          UPDATE #{table}
          SET core_rules = #{quote(slug)}
          WHERE core_rules = #{quote(display_name)}
        SQL
      end
    end
  end

  def down
    TABLES.each do |table|
      SLUG_TO_DISPLAY_NAME.each do |slug, display_name|
        execute <<~SQL
          UPDATE #{table}
          SET core_rules = #{quote(display_name)}
          WHERE core_rules = #{quote(slug)}
        SQL
      end
    end
  end
end
