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

end
