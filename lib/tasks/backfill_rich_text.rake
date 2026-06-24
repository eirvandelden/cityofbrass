# Repair command for ActionText::RichText records from legacy text columns.
# The backfill runs automatically during db:migrate via BackfillActionTextRichTexts.
# Run this task only to repair missing records after a failed migration or data incident.
# Idempotent: skips records that already have ActionText content.
# Run: bin/rails rich_text:backfill
namespace :rich_text do
  desc "Backfill ActionText rich text from legacy HTML columns"
  task backfill: :environment do
    backfills = [
      { model: "Message",                     field: "body" },
      { model: "Resident",                    field: "full_description" },
      { model: "Rulebuilder::Rule",           field: "full_description" },
      { model: "Rulebuilder::Rule",           field: "benefit" },
      { model: "Rulebuilder::Rule",           field: "normal" },
      { model: "Rulebuilder::Rule",           field: "special" },
      { model: "Rulebuilder::Spell",          field: "full_description" },
      { model: "Rulebuilder::Item",           field: "full_description" },
      { model: "Storybuilder::Section",       field: "content" },
      { model: "Storybuilder::Adventure",     field: "full_description" },
      { model: "Storybuilder::Page",          field: "full_description" },
      { model: "Campaignmanager::Campaign",   field: "full_description" },
      { model: "Campaignmanager::Page",       field: "full_description" },
      { model: "Campaignmanager::Section",    field: "content" },
      { model: "Worldbuilder::District",      field: "full_description" },
      { model: "Worldbuilder::Page",          field: "full_description" },
      { model: "Worldbuilder::Section",       field: "content" },
      { model: "Support::Faq",               field: "answer" },
      { model: "Entitybuilder::Entity",       field: "full_description" },
      { model: "Entitybuilder::Entity",       field: "introduction" },
      { model: "Entitybuilder::Entity",       field: "notes" }
    ]

    backfills.each do |entry|
      klass = entry[:model].constantize
      field = entry[:field]
      table = klass.table_name
      rich_text_name = "#{field}"

      puts "\n== Backfilling #{entry[:model]}##{field} =="

      total = 0
      skipped = 0
      migrated = 0

      klass.find_each do |record|
        total += 1
        legacy_value = record.read_attribute(field)

        if legacy_value.blank?
          skipped += 1
          next
        end

        existing = ActionText::RichText.find_by(
          record_type: klass.base_class.name,
          record_id:   record.id,
          name:        rich_text_name
        )

        if existing.present?
          skipped += 1
          next
        end

        ActionText::RichText.create!(
          record_type: klass.base_class.name,
          record_id:   record.id,
          name:        rich_text_name,
          body:        legacy_value
        )
        migrated += 1
      rescue => e
        puts "  ERROR on #{entry[:model]} id=#{record.id}: #{e.message}"
      end

      puts "   total=#{total} migrated=#{migrated} skipped=#{skipped}"
    end

    puts "\nDone."
  end
end
