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

ActiveRecord::Schema.define(version: 2016_04_14_110411) do

  create_table "rulebuilder_abilities", id: :string, force: :cascade do |t|
    t.string "type", null: false
    t.string "resident_id"
    t.string "core_rules"
    t.string "name"
    t.string "short_description"
    t.text "full_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "parent_id"
    t.string "publisher"
    t.string "source"
    t.boolean "is_3pp", default: false
    t.text "tags"
    t.index ["parent_id"], name: "index_rulebuilder_abilities_on_parent_id"
    t.index ["resident_id"], name: "index_rulebuilder_abilities_on_resident_id"
    t.index ["tags"], name: "index_rulebuilder_abilities_on_tags"
    t.index ["type"], name: "index_rulebuilder_abilities_on_type"
  end

  create_table "rulebuilder_feats", id: :string, force: :cascade do |t|
    t.string "type", null: false
    t.string "resident_id"
    t.string "core_rules"
    t.string "name"
    t.string "short_description"
    t.text "full_description"
    t.string "prerequisites"
    t.text "benefit"
    t.text "normal"
    t.text "special"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "categories"
    t.string "parent_id"
    t.string "publisher"
    t.string "source"
    t.boolean "is_3pp", default: false
    t.text "tags"
    t.index ["categories"], name: "index_rulebuilder_feats_on_categories"
    t.index ["parent_id"], name: "index_rulebuilder_feats_on_parent_id"
    t.index ["resident_id"], name: "index_rulebuilder_feats_on_resident_id"
    t.index ["tags"], name: "index_rulebuilder_feats_on_tags"
    t.index ["type"], name: "index_rulebuilder_feats_on_type"
  end

  create_table "rulebuilder_items", id: :string, force: :cascade do |t|
    t.string "type", null: false
    t.string "resident_id"
    t.string "core_rules"
    t.string "name"
    t.string "short_description"
    t.text "full_description"
    t.text "category"
    t.decimal "weight"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "parent_id"
    t.string "publisher"
    t.string "source"
    t.boolean "is_3pp", default: false
    t.text "tags"
    t.index ["parent_id"], name: "index_rulebuilder_items_on_parent_id"
    t.index ["resident_id"], name: "index_rulebuilder_items_on_resident_id"
    t.index ["tags"], name: "index_rulebuilder_items_on_tags"
    t.index ["type"], name: "index_rulebuilder_items_on_type"
  end

  create_table "rulebuilder_rules", id: :string, force: :cascade do |t|
    t.string "type", null: false
    t.string "resident_id"
    t.string "parent_id"
    t.string "core_rules"
    t.string "rule_type"
    t.boolean "is_shared"
    t.string "name"
    t.string "short_description"
    t.text "full_description"
    t.string "publisher"
    t.string "source"
    t.boolean "is_3pp"
    t.text "tags"
    t.text "categories"
    t.string "prerequisites"
    t.text "benefit"
    t.text "normal"
    t.text "special"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["categories"], name: "index_rulebuilder_rules_on_categories"
    t.index ["parent_id"], name: "index_rulebuilder_rules_on_parent_id"
    t.index ["resident_id"], name: "index_rulebuilder_rules_on_resident_id"
    t.index ["tags"], name: "index_rulebuilder_rules_on_tags"
    t.index ["type"], name: "index_rulebuilder_rules_on_type"
  end

  create_table "rulebuilder_spells", id: :string, force: :cascade do |t|
    t.string "type", null: false
    t.string "resident_id"
    t.string "core_rules"
    t.string "name"
    t.string "short_description"
    t.text "full_description"
    t.string "school"
    t.string "casting_time"
    t.string "components"
    t.string "range"
    t.string "effect"
    t.string "target"
    t.string "area"
    t.string "duration"
    t.string "saving_throw"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "spell_resistance"
    t.text "levels"
    t.string "parent_id"
    t.string "publisher"
    t.string "source"
    t.boolean "is_3pp", default: false
    t.text "tags"
    t.index ["levels"], name: "index_rulebuilder_spells_on_levels"
    t.index ["parent_id"], name: "index_rulebuilder_spells_on_parent_id"
    t.index ["resident_id"], name: "index_rulebuilder_spells_on_resident_id"
    t.index ["tags"], name: "index_rulebuilder_spells_on_tags"
    t.index ["type"], name: "index_rulebuilder_spells_on_type"
  end

  create_table "worldbuilder_contributors", id: :string, force: :cascade do |t|
    t.string "district_id", null: false
    t.string "affiliation_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["district_id", "affiliation_id"], name: "index_worldbuilder_contributers_district_and_affiliate", unique: true
  end

  create_table "worldbuilder_districts", id: :string, force: :cascade do |t|
    t.string "resident_id"
    t.string "name", null: false
    t.string "slug", null: false
    t.string "short_description"
    t.text "full_description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "privacy"
    t.string "page_label"
    t.index ["resident_id"], name: "index_worldbuilder_districts_on_resident_id"
    t.index ["slug"], name: "index_worldbuilder_districts_on_slug", unique: true
  end

  create_table "worldbuilder_features", id: :string, force: :cascade do |t|
    t.string "featureable_id"
    t.string "featureable_type"
    t.integer "sort_order"
    t.string "feature_label"
    t.text "feature_text"
    t.string "feature_type"
    t.string "record_type"
    t.string "search_tags"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["featureable_id", "featureable_type"], name: "index_worldbuilder_features_id_and_type"
  end

  create_table "worldbuilder_menu_item_joins", id: :string, force: :cascade do |t|
    t.string "menu_item_id", null: false
    t.string "menu_item_joinable_id", null: false
    t.string "menu_item_joinable_type", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["menu_item_id"], name: "index_worldbuilder_menu_item_joins_on_menu_item_id"
    t.index ["menu_item_joinable_id", "menu_item_joinable_type"], name: "wb_menu_item_joins_id_and_type"
  end

  create_table "worldbuilder_menu_items", id: :string, force: :cascade do |t|
    t.string "menu_itemable_id"
    t.string "menu_itemable_type"
    t.integer "sort_order"
    t.string "item_label"
    t.string "item_link"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["menu_itemable_id", "menu_itemable_type"], name: "wb_menu_items_id_and_type"
  end

  create_table "worldbuilder_pages", id: :string, force: :cascade do |t|
    t.string "type"
    t.string "district_id"
    t.string "parent_id"
    t.string "name"
    t.string "slug"
    t.string "page_label"
    t.string "short_description"
    t.text "full_description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "tags"
    t.integer "sort_weight", default: 1000, null: false
    t.index ["district_id", "slug"], name: "index_worldbuilder_pages_on_district_id_and_slug"
    t.index ["parent_id"], name: "index_worldbuilder_pages_on_parent_id"
    t.index ["tags"], name: "index_worldbuilder_pages_on_tags"
  end

  create_table "worldbuilder_sections", id: :string, force: :cascade do |t|
    t.string "sectionable_id"
    t.string "sectionable_type"
    t.integer "sort_order"
    t.string "header"
    t.text "content"
    t.string "section_type"
    t.string "section_style"
    t.string "record_type"
    t.string "search_tags"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["sectionable_id", "sectionable_type"], name: "index_worldbuilder_sections_id_and_type"
  end

end
