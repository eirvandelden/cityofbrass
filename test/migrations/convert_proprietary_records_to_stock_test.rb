require "test_helper"
require Rails.root.join("db/migrate/20260613000001_convert_proprietary_records_to_stock")

class ConvertProprietaryRecordsToStockTest < ActiveSupport::TestCase
  test "updates polymorphic references for converted records" do
    creature_id = insert_entity("Entitybuilder::ProprietaryCreature")
    rule_id = insert_rule("Rulebuilder::ProprietaryRule")
    image_id = insert_image
    insert_image_join(image_id, creature_id, "Entitybuilder::ProprietaryCreature")
    insert_image_join(image_id, rule_id, "Rulebuilder::ProprietaryRule")
    insert_notable(creature_id, "Entitybuilder::ProprietaryCreature")

    ConvertProprietaryRecordsToStock.new.up

    assert_equal "Entitybuilder::StockCreature", entity_type(creature_id)
    assert_equal [ "Entitybuilder::StockCreature" ], imageable_types(creature_id)
    assert_equal [ "Rulebuilder::StockRule" ], imageable_types(rule_id)
    assert_equal [ "Entitybuilder::StockCreature" ], notableable_types(creature_id)
  end

  private
    def insert_entity(type)
      insert_row(
        "entitybuilder_entities",
        type: type,
        name: "Legacy creature",
        core_rules: "PFRPG",
        privacy: "Residents",
        sheet_privacy: "Residents",
        created_at: Time.current,
        updated_at: Time.current
      )
    end

    def insert_rule(type)
      insert_row(
        "rulebuilder_rules",
        type: type,
        core_rules: "PFRPG",
        rule_type: "Feat",
        name: "Legacy rule",
        created_at: Time.current,
        updated_at: Time.current
      )
    end

    def insert_image
      insert_row("gallery_images", type: "Gallery::StockImage", name: "Legacy image")
    end

    def insert_image_join(image_id, imageable_id, imageable_type)
      insert_row(
        "gallery_image_joins",
        image_id: image_id,
        imageable_id: imageable_id,
        imageable_type: imageable_type
      )
    end

    def insert_notable(notableable_id, notableable_type)
      insert_row(
        "entitybuilder_notables",
        notableable_id: notableable_id,
        notableable_type: notableable_type,
        entity_id: notableable_id,
        name: "Legacy notable",
        created_at: Time.current,
        updated_at: Time.current
      )
    end

    def insert_row(table_name, attributes)
      id = SecureRandom.uuid
      values = attributes.merge(id: id)
      columns = values.keys.map { |column| quote_column(column) }.join(", ")
      quoted_values = values.values.map { |value| connection.quote(value) }.join(", ")

      connection.execute("INSERT INTO #{quote_table(table_name)} (#{columns}) VALUES (#{quoted_values})")
      id
    end

    def entity_type(id)
      select_value("entitybuilder_entities", "type", id)
    end

    def imageable_types(id)
      select_values("gallery_image_joins", "imageable_type", "imageable_id", id)
    end

    def notableable_types(id)
      select_values("entitybuilder_notables", "notableable_type", "notableable_id", id)
    end

    def select_value(table_name, column_name, id)
      connection.select_value(<<~SQL.squish)
        SELECT #{quote_column(column_name)}
        FROM #{quote_table(table_name)}
        WHERE id = #{connection.quote(id)}
      SQL
    end

    def select_values(table_name, column_name, id_column, id)
      connection.select_values(<<~SQL.squish)
        SELECT #{quote_column(column_name)}
        FROM #{quote_table(table_name)}
        WHERE #{quote_column(id_column)} = #{connection.quote(id)}
      SQL
    end

    def quote_table(table_name)
      connection.quote_table_name(table_name)
    end

    def quote_column(column_name)
      connection.quote_column_name(column_name)
    end

    def connection
      ActiveRecord::Base.connection
    end
end
