# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2016_06_04_113631) do
  create_table "entitybuilder_ability_scores", id: :string, force: :cascade do |t|
    t.string "entity_id"
    t.integer "sort_order"
    t.string "name", null: false
    t.text "description"
    t.integer "base"
    t.integer "score"
    t.integer "modifier"
    t.string "dice"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index [ "entity_id" ], name: "index_entitybuilder_ability_scores_on_entity_id"
  end

  create_table "entitybuilder_attacks", id: :string, force: :cascade do |t|
    t.string "entity_id"
    t.integer "sort_order"
    t.string "name", null: false
    t.text "description"
    t.string "attack_type"
    t.string "attack_range"
    t.string "attack_ability_score"
    t.string "attack_dice"
    t.integer "attack_bonus"
    t.integer "attack_misc_modifier"
    t.string "damage_ability_score"
    t.string "damage_dice"
    t.integer "damage_bonus"
    t.integer "damage_misc_modifier"
    t.string "critical_range"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "proficient"
    t.string "damage_type"
    t.string "critical_damage_ability_score"
    t.string "critical_damage_dice"
    t.integer "critical_damage_bonus"
    t.integer "critical_damage_misc_modifier"
    t.string "special_damage_ability_score"
    t.string "special_damage_dice"
    t.integer "special_damage_bonus"
    t.integer "special_damage_misc_modifier"
    t.string "special_damage_name"
    t.index [ "entity_id" ], name: "index_entitybuilder_attacks_on_entity_id"
  end

  create_table "entitybuilder_base_values", id: :string, force: :cascade do |t|
    t.string "entity_id"
    t.integer "sort_order"
    t.string "name", null: false
    t.text "description"
    t.integer "value"
    t.string "dice"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index [ "entity_id" ], name: "index_entitybuilder_base_values_on_entity_id"
  end

  create_table "entitybuilder_campaign_joins", id: :string, force: :cascade do |t|
    t.string "entity_id"
    t.string "campaign_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index [ "entity_id" ], name: "index_entitybuilder_campaign_joins_on_entity_id"
  end

  create_table "entitybuilder_caster_levels", id: :string, force: :cascade do |t|
    t.string "entity_id"
    t.integer "sort_order"
    t.string "caster_class"
    t.integer "level"
    t.integer "per_day"
    t.integer "bonus_per_day"
    t.integer "base_dc"
    t.string "ability_score"
    t.integer "save_dc"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "proficient"
    t.index [ "entity_id" ], name: "index_entitybuilder_caster_levels_on_entity_id"
  end

  create_table "entitybuilder_class_levels", id: :string, force: :cascade do |t|
    t.string "entity_id"
    t.integer "sort_order"
    t.string "name", null: false
    t.text "description"
    t.integer "level"
    t.string "hit_dice"
    t.integer "hit_points"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index [ "entity_id" ], name: "index_entitybuilder_class_levels_on_entity_id"
  end

  create_table "entitybuilder_currencies", id: :string, force: :cascade do |t|
    t.string "entity_id"
    t.integer "sort_order"
    t.string "name"
    t.text "description"
    t.decimal "weight"
    t.integer "quantity"
    t.boolean "carried"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index [ "entity_id" ], name: "index_entitybuilder_currencies_on_entity_id"
  end

  create_table "entitybuilder_defenses", id: :string, force: :cascade do |t|
    t.string "entity_id"
    t.integer "sort_order"
    t.string "name", null: false
    t.text "description"
    t.integer "base"
    t.integer "bonus"
    t.string "ability_score"
    t.integer "misc_modifier"
    t.string "dice"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index [ "entity_id" ], name: "index_entitybuilder_defenses_on_entity_id"
  end

  create_table "entitybuilder_descriptors", id: :string, force: :cascade do |t|
    t.string "entity_id"
    t.integer "sort_order"
    t.string "name", null: false
    t.string "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_private", default: false
    t.index [ "entity_id" ], name: "index_entitybuilder_descriptors_on_entity_id"
  end

  create_table "entitybuilder_entities", id: :string, force: :cascade do |t|
    t.string "type", null: false
    t.string "resident_id"
    t.string "name"
    t.string "core_rules"
    t.string "privacy"
    t.string "sheet_privacy"
    t.string "short_description"
    t.text "full_description"
    t.text "introduction"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "publisher"
    t.string "source"
    t.boolean "is_3pp", default: false
    t.text "tags"
    t.index [ "resident_id" ], name: "index_entitybuilder_entities_on_resident_id"
    t.index [ "tags" ], name: "index_entitybuilder_entities_on_tags"
    t.index [ "type" ], name: "index_entitybuilder_entities_on_type"
  end

  create_table "entitybuilder_inventory_items", id: :string, force: :cascade do |t|
    t.string "entity_id"
    t.integer "sort_order"
    t.string "item_id"
    t.integer "quantity"
    t.boolean "equipped"
    t.boolean "carried"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "detail"
    t.index [ "entity_id" ], name: "index_entitybuilder_inventory_items_on_entity_id"
    t.index [ "item_id" ], name: "index_entitybuilder_inventory_items_on_item_id"
  end

  create_table "entitybuilder_known_abilities", id: :string, force: :cascade do |t|
    t.string "entity_id"
    t.integer "sort_order"
    t.string "ability_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "detail"
    t.index [ "ability_id" ], name: "index_entitybuilder_known_abilities_on_ability_id"
    t.index [ "entity_id" ], name: "index_entitybuilder_known_abilities_on_entity_id"
  end

  create_table "entitybuilder_known_feats", id: :string, force: :cascade do |t|
    t.string "entity_id"
    t.integer "sort_order"
    t.string "feat_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "detail"
    t.index [ "entity_id" ], name: "index_entitybuilder_known_feats_on_entity_id"
    t.index [ "feat_id" ], name: "index_entitybuilder_known_feats_on_feat_id"
  end

  create_table "entitybuilder_known_spells", id: :string, force: :cascade do |t|
    t.string "entity_id"
    t.integer "sort_order"
    t.string "spell_id"
    t.boolean "prepared"
    t.boolean "used"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "spell_class"
    t.integer "level"
    t.string "detail"
    t.boolean "at_will", default: false
    t.index [ "entity_id" ], name: "index_entitybuilder_known_spells_on_entity_id"
    t.index [ "spell_id" ], name: "index_entitybuilder_known_spells_on_spell_id"
  end

  create_table "entitybuilder_linked_rules", id: :string, force: :cascade do |t|
    t.string "entity_id"
    t.string "rule_id"
    t.integer "sort_order"
    t.string "detail"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "entity_id" ], name: "index_entitybuilder_linked_rules_on_entity_id"
    t.index [ "rule_id" ], name: "index_entitybuilder_linked_rules_on_rule_id"
  end

  create_table "entitybuilder_modifiers", id: :string, force: :cascade do |t|
    t.string "modifierable_id"
    t.string "modifierable_type"
    t.string "entity_id"
    t.integer "sort_order"
    t.string "category"
    t.string "item"
    t.integer "value"
    t.string "dice"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "original_mod_type"
    t.index [ "entity_id" ], name: "index_entitybuilder_modifiers_on_entity_id"
    t.index [ "modifierable_id", "modifierable_type" ], name: "eb_modifier_id_and_type"
  end

  create_table "entitybuilder_movements", id: :string, force: :cascade do |t|
    t.string "entity_id"
    t.integer "sort_order"
    t.string "name", null: false
    t.integer "base"
    t.string "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "bonus"
    t.string "ability_score"
    t.integer "misc_modifier"
    t.string "dice"
    t.index [ "entity_id" ], name: "index_entitybuilder_movements_on_entity_id"
  end

  create_table "entitybuilder_notables", id: :string, force: :cascade do |t|
    t.string "notableable_id"
    t.string "notableable_type"
    t.string "entity_id"
    t.string "name"
    t.integer "sort_order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "entity_id" ], name: "index_entitybuilder_notables_on_entity_id"
    t.index [ "notableable_id", "notableable_type" ], name: "eb_notable_id_and_type"
  end

  create_table "entitybuilder_saving_throws", id: :string, force: :cascade do |t|
    t.string "entity_id"
    t.integer "sort_order"
    t.string "name"
    t.text "description"
    t.integer "base"
    t.integer "bonus"
    t.string "ability_score"
    t.integer "misc_modifier"
    t.string "dice"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "proficient"
    t.index [ "entity_id" ], name: "index_entitybuilder_saving_throws_on_entity_id"
  end

  create_table "entitybuilder_skills", id: :string, force: :cascade do |t|
    t.string "entity_id"
    t.integer "sort_order"
    t.string "name", null: false
    t.text "description"
    t.integer "bonus"
    t.boolean "class_skill"
    t.string "ability_score"
    t.integer "ranks"
    t.integer "misc_modifier"
    t.string "dice"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "proficient"
    t.index [ "entity_id" ], name: "index_entitybuilder_skills_on_entity_id"
  end

  create_table "entitybuilder_trackables", id: :string, force: :cascade do |t|
    t.string "entity_id"
    t.integer "sort_order"
    t.string "name", null: false
    t.text "description"
    t.integer "minimum"
    t.integer "maximum"
    t.integer "current"
    t.integer "temporary"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index [ "entity_id" ], name: "index_entitybuilder_trackables_on_entity_id"
  end

  create_table "entitybuilder_traits", id: :string, force: :cascade do |t|
    t.string "entity_id"
    t.integer "sort_order"
    t.string "name", null: false
    t.string "short_description"
    t.text "full_description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "detail"
    t.index [ "entity_id" ], name: "index_entitybuilder_traits_on_entity_id"
  end
end
