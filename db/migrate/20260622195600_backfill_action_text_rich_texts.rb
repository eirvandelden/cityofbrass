class BackfillActionTextRichTexts < ActiveRecord::Migration[6.1]
  MAPPINGS = [
    [ "messages",                  "Message",                    "body"             ],
    [ "residents",                 "Resident",                   "full_description" ],
    [ "rulebuilder_rules",         "Rulebuilder::Rule",          "full_description" ],
    [ "rulebuilder_rules",         "Rulebuilder::Rule",          "benefit"          ],
    [ "rulebuilder_rules",         "Rulebuilder::Rule",          "normal"           ],
    [ "rulebuilder_rules",         "Rulebuilder::Rule",          "special"          ],
    [ "rulebuilder_spells",        "Rulebuilder::Spell",         "full_description" ],
    [ "rulebuilder_items",         "Rulebuilder::Item",          "full_description" ],
    [ "storybuilder_sections",     "Storybuilder::Section",      "content"          ],
    [ "storybuilder_adventures",   "Storybuilder::Adventure",    "full_description" ],
    [ "storybuilder_pages",        "Storybuilder::Page",         "full_description" ],
    [ "campaignmanager_campaigns", "Campaignmanager::Campaign",  "full_description" ],
    [ "campaignmanager_pages",     "Campaignmanager::Page",      "full_description" ],
    [ "campaignmanager_sections",  "Campaignmanager::Section",   "content"          ],
    [ "worldbuilder_districts",    "Worldbuilder::District",     "full_description" ],
    [ "worldbuilder_pages",        "Worldbuilder::Page",         "full_description" ],
    [ "worldbuilder_sections",     "Worldbuilder::Section",      "content"          ],
    [ "support_faqs",              "Support::Faq",               "answer"           ],
    [ "entitybuilder_entities",    "Entitybuilder::Entity",      "full_description" ],
    [ "entitybuilder_entities",    "Entitybuilder::Entity",      "introduction"     ],
    [ "entitybuilder_entities",    "Entitybuilder::Entity",      "notes"            ]
  ].freeze

  def up
    MAPPINGS.each do |table, record_type, name|
      execute(<<~SQL)
        INSERT INTO action_text_rich_texts (name, body, record_type, record_id, created_at, updated_at)
        SELECT
          '#{name}',
          src.#{name},
          '#{record_type}',
          src.id,
          CURRENT_TIMESTAMP,
          CURRENT_TIMESTAMP
        FROM #{table} src
        WHERE src.#{name} IS NOT NULL
          AND src.#{name} != ''
          AND NOT EXISTS (
            SELECT 1 FROM action_text_rich_texts art
            WHERE art.record_type = '#{record_type}'
              AND art.record_id   = src.id
              AND art.name        = '#{name}'
          )
      SQL
    end
  end

  def down
    MAPPINGS.each do |_table, record_type, name|
      execute(<<~SQL)
        DELETE FROM action_text_rich_texts
        WHERE record_type = '#{record_type}'
          AND name        = '#{name}'
      SQL
    end
  end
end
