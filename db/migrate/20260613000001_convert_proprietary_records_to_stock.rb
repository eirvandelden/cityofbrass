class ConvertProprietaryRecordsToStock < ActiveRecord::Migration[6.1]
  TYPE_MAPPINGS = {
    "entitybuilder_entities" => {
      "Entitybuilder::ProprietaryCreature" => "Entitybuilder::StockCreature",
      "Entitybuilder::ProprietaryNpc" => "Entitybuilder::StockNpc"
    },
    "gallery_images" => {
      "Gallery::ProprietaryImage" => "Gallery::StockImage"
    },
    "rulebuilder_items" => {
      "Rulebuilder::ProprietaryItem" => "Rulebuilder::StockItem"
    },
    "rulebuilder_rules" => {
      "Rulebuilder::ProprietaryRule" => "Rulebuilder::StockRule"
    },
    "rulebuilder_spells" => {
      "Rulebuilder::ProprietarySpell" => "Rulebuilder::StockSpell"
    }
  }.freeze

  def up
    TYPE_MAPPINGS.each do |table_name, mappings|
      mappings.each do |old_type, new_type|
        update_types(table_name, old_type, new_type)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private
    def update_types(table_name, old_type, new_type)
      update(<<~SQL.squish)
        UPDATE #{quote_table_name(table_name)}
        SET type = #{quote(new_type)}
        WHERE type = #{quote(old_type)}
      SQL
    end
end
