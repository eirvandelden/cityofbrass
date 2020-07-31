# frozen_string_literal: false

# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150308213405) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "billing_plans", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name",              null: false
    t.string   "stripe_plan_token"
    t.string   "interval"
    t.integer  "interval_count"
    t.string   "currency"
    t.integer  "amount"
    t.string   "short_description"
    t.string   "full_description"
    t.integer  "trial_period_days"
    t.boolean  "active"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "campaignmanager_campaigns", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "resident_id",                   null: false
    t.string   "name",              limit: 255, null: false
    t.string   "slug",              limit: 255, null: false
    t.string   "page_label",        limit: 255
    t.string   "privacy",           limit: 255, null: false
    t.string   "short_description", limit: 255
    t.text     "full_description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "campaignmanager_campaigns", ["resident_id", "slug"], name: "index_campaignmanager_campaigns_on_resident_id_and_slug", unique: true, using: :btree

  create_table "campaignmanager_features", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "featureable_id"
    t.string   "featureable_type", limit: 255
    t.integer  "sort_order"
    t.string   "feature_label",    limit: 255
    t.text     "feature_text"
    t.string   "feature_type",     limit: 255
    t.string   "record_type",      limit: 255
    t.string   "search_tags",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "campaignmanager_features", ["featureable_id", "featureable_type"], name: "index_campaignmanager_features_id_and_type", using: :btree

  create_table "campaignmanager_pages", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "type",              limit: 255, null: false
    t.uuid     "resident_id"
    t.uuid     "campaign_id"
    t.uuid     "parent_id"
    t.string   "name",              limit: 255
    t.string   "slug",              limit: 255
    t.string   "page_label",        limit: 255
    t.string   "privacy",           limit: 255
    t.string   "short_description", limit: 255
    t.text     "full_description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "campaignmanager_pages", ["campaign_id", "type", "slug"], name: "index_campaignmanager_pages_on_campaign_id_and_type_and_slug", unique: true, using: :btree
  add_index "campaignmanager_pages", ["resident_id"], name: "index_campaignmanager_pages_on_resident_id", using: :btree

  create_table "campaignmanager_players", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "campaign_id"
    t.uuid     "affiliation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "campaignmanager_players", ["campaign_id", "affiliation_id"], name: "index_campaignmanager_players_campaign_and_affiliate", unique: true, using: :btree

  create_table "campaignmanager_sections", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "sectionable_id"
    t.string   "sectionable_type", limit: 255
    t.integer  "sort_order"
    t.string   "header",           limit: 255
    t.text     "content"
    t.string   "section_type",     limit: 255
    t.string   "section_style",    limit: 255
    t.string   "record_type",      limit: 255
    t.string   "search_tags",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "campaignmanager_sections", ["sectionable_id", "sectionable_type"], name: "index_campaignmanager_sections_id_and_type", using: :btree

  create_table "entitybuilder_ability_scores", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "ability_scoreable_id"
    t.string   "ability_scoreable_type", limit: 255
    t.integer  "sort_order"
    t.string   "name",                   limit: 255, null: false
    t.text     "description"
    t.integer  "base"
    t.integer  "score"
    t.integer  "modifier"
    t.string   "dice",                   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "entitybuilder_ability_scores", ["ability_scoreable_id", "ability_scoreable_type"], name: "eb_ability_score_id_and_type", using: :btree
  add_index "entitybuilder_ability_scores", ["ability_scoreable_id", "name"], name: "eb_ability_score_name", unique: true, using: :btree

  create_table "entitybuilder_attacks", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "attackable_id"
    t.string   "attackable_type",               limit: 255
    t.integer  "sort_order"
    t.string   "name",                          limit: 255, null: false
    t.text     "description"
    t.string   "attack_type",                   limit: 255
    t.string   "attack_range",                  limit: 255
    t.string   "attack_ability_score",          limit: 255
    t.string   "attack_dice",                   limit: 255
    t.integer  "attack_bonus"
    t.integer  "attack_misc_modifier"
    t.string   "damage_ability_score",          limit: 255
    t.string   "damage_dice",                   limit: 255
    t.integer  "damage_bonus"
    t.integer  "damage_misc_modifier"
    t.string   "critical_range",                limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "proficient"
    t.string   "damage_type",                   limit: 255
    t.string   "critical_damage_ability_score", limit: 255
    t.string   "critical_damage_dice",          limit: 255
    t.integer  "critical_damage_bonus"
    t.integer  "critical_damage_misc_modifier"
    t.string   "special_damage_ability_score",  limit: 255
    t.string   "special_damage_dice",           limit: 255
    t.integer  "special_damage_bonus"
    t.integer  "special_damage_misc_modifier"
    t.string   "special_damage_name",           limit: 255
  end

  add_index "entitybuilder_attacks", ["attackable_id", "attackable_type"], name: "eb_attack_id_and_type", using: :btree
  add_index "entitybuilder_attacks", ["attackable_id", "name"], name: "eb_attack_name", unique: true, using: :btree

  create_table "entitybuilder_base_values", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "base_valueable_id"
    t.string   "base_valueable_type", limit: 255
    t.integer  "sort_order"
    t.string   "name",                limit: 255, null: false
    t.text     "description"
    t.integer  "value"
    t.string   "dice",                limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "entitybuilder_base_values", ["base_valueable_id", "base_valueable_type"], name: "eb_base_value_id_and_type", using: :btree
  add_index "entitybuilder_base_values", ["base_valueable_id", "name"], name: "eb_base_value_name", unique: true, using: :btree

  create_table "entitybuilder_campaign_joins", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "campaign_joinable_id"
    t.string   "campaign_joinable_type", limit: 255
    t.uuid     "campaign_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "entitybuilder_campaign_joins", ["campaign_joinable_id", "campaign_joinable_type"], name: "eb_campaign_join_id_and_type", using: :btree

  create_table "entitybuilder_caster_levels", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "caster_levelable_id"
    t.string   "caster_levelable_type", limit: 255
    t.integer  "sort_order"
    t.string   "caster_class",          limit: 255
    t.integer  "level"
    t.integer  "per_day"
    t.integer  "bonus_per_day"
    t.integer  "base_dc"
    t.string   "ability_score",         limit: 255
    t.integer  "save_dc"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "proficient"
  end

  add_index "entitybuilder_caster_levels", ["caster_levelable_id", "caster_levelable_type"], name: "eb_caster_level_id_and_type", using: :btree

  create_table "entitybuilder_characteristics", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "characteristicable_id"
    t.string   "characteristicable_type", limit: 255
    t.integer  "sort_order"
    t.string   "name",                    limit: 255, null: false
    t.string   "short_description",       limit: 255
    t.text     "full_description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "entitybuilder_characteristics", ["characteristicable_id", "characteristicable_type"], name: "eb_characteristic_id_and_type", using: :btree
  add_index "entitybuilder_characteristics", ["characteristicable_id", "name"], name: "eb_characteristic_name", unique: true, using: :btree

  create_table "entitybuilder_characters", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "resident_id",                   null: false
    t.string   "name",              limit: 255, null: false
    t.string   "slug",              limit: 255
    t.string   "race",              limit: 255
    t.string   "privacy",           limit: 255
    t.string   "sheet_privacy",     limit: 255
    t.string   "core_rules",        limit: 255
    t.string   "short_description", limit: 255
    t.text     "full_description"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sheet_font",        limit: 255
  end

  add_index "entitybuilder_characters", ["resident_id", "slug"], name: "index_entitybuilder_characters_on_resident_id_and_slug", unique: true, using: :btree

  create_table "entitybuilder_class_levels", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "class_levelable_id"
    t.string   "class_levelable_type", limit: 255
    t.integer  "sort_order"
    t.string   "name",                 limit: 255, null: false
    t.text     "description"
    t.integer  "level"
    t.string   "hit_dice",             limit: 255
    t.integer  "hit_points"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "entitybuilder_class_levels", ["class_levelable_id", "class_levelable_type"], name: "eb_class_level_id_and_type", using: :btree

  create_table "entitybuilder_creatures", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "resident_id",                   null: false
    t.string   "name",              limit: 255, null: false
    t.string   "privacy",           limit: 255
    t.string   "core_rules",        limit: 255
    t.string   "short_description", limit: 255
    t.text     "full_description"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "entitybuilder_creatures", ["resident_id"], name: "index_entitybuilder_creatures_on_resident_id", using: :btree

  create_table "entitybuilder_currencies", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "currencyable_id"
    t.string   "currencyable_type", limit: 255
    t.integer  "sort_order"
    t.string   "name",              limit: 255
    t.text     "description"
    t.decimal  "weight"
    t.integer  "quantity"
    t.boolean  "carried"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "entitybuilder_currencies", ["currencyable_id", "currencyable_type"], name: "eb_currency_id_and_type", using: :btree
  add_index "entitybuilder_currencies", ["currencyable_id", "name"], name: "eb_currency_name", unique: true, using: :btree

  create_table "entitybuilder_defenses", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "defenseable_id"
    t.string   "defenseable_type", limit: 255
    t.integer  "sort_order"
    t.string   "name",             limit: 255, null: false
    t.text     "description"
    t.integer  "base"
    t.integer  "bonus"
    t.string   "ability_score",    limit: 255
    t.integer  "misc_modifier"
    t.string   "dice",             limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "entitybuilder_defenses", ["defenseable_id", "defenseable_type"], name: "eb_defense_id_and_type", using: :btree
  add_index "entitybuilder_defenses", ["defenseable_id", "name"], name: "eb_defense_name", unique: true, using: :btree

  create_table "entitybuilder_descriptors", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "descriptorable_id"
    t.string   "descriptorable_type", limit: 255
    t.integer  "sort_order"
    t.string   "name",                limit: 255, null: false
    t.string   "description",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "entitybuilder_descriptors", ["descriptorable_id", "descriptorable_type"], name: "eb_descriptor_id_and_type", using: :btree
  add_index "entitybuilder_descriptors", ["descriptorable_id", "name"], name: "eb_descriptor_name", unique: true, using: :btree

  create_table "entitybuilder_feats", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name",              limit: 255, null: false
    t.string   "short_description", limit: 255
    t.text     "full_description"
    t.string   "prerequisites",     limit: 255
    t.text     "benefit"
    t.text     "normal"
    t.text     "special"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.uuid     "resident_id"
    t.string   "core_rules",        limit: 255
  end

  add_index "entitybuilder_feats", ["resident_id"], name: "index_entitybuilder_feats_on_resident_id", using: :btree

  create_table "entitybuilder_inventory_items", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "inventory_itemable_id"
    t.string   "inventory_itemable_type", limit: 255
    t.integer  "sort_order"
    t.uuid     "item_id"
    t.integer  "quantity"
    t.boolean  "equipped"
    t.boolean  "carried"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "entitybuilder_inventory_items", ["inventory_itemable_id", "inventory_itemable_type"], name: "eb_inventory_item_id_and_type", using: :btree
  add_index "entitybuilder_inventory_items", ["item_id"], name: "index_entitybuilder_inventory_items_on_item_id", using: :btree

  create_table "entitybuilder_items", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name",              limit: 255, null: false
    t.string   "short_description", limit: 255
    t.text     "full_description"
    t.text     "category"
    t.decimal  "weight"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "proficient"
    t.uuid     "resident_id"
    t.string   "core_rules",        limit: 255
  end

  add_index "entitybuilder_items", ["resident_id"], name: "index_entitybuilder_items_on_resident_id", using: :btree

  create_table "entitybuilder_known_feats", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "known_featable_id"
    t.string   "known_featable_type", limit: 255
    t.integer  "sort_order"
    t.uuid     "feat_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "entitybuilder_known_feats", ["feat_id"], name: "index_entitybuilder_known_feats_on_feat_id", using: :btree
  add_index "entitybuilder_known_feats", ["known_featable_id", "known_featable_type"], name: "eb_known_feat_id_and_type", using: :btree

  create_table "entitybuilder_known_spells", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "known_spellable_id"
    t.string   "known_spellable_type", limit: 255
    t.integer  "sort_order"
    t.uuid     "spell_id"
    t.boolean  "prepared"
    t.boolean  "used"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "entitybuilder_known_spells", ["known_spellable_id", "known_spellable_type"], name: "eb_known_spell_id_and_type", using: :btree
  add_index "entitybuilder_known_spells", ["spell_id"], name: "index_entitybuilder_known_spells_on_spell_id", using: :btree

  create_table "entitybuilder_modifiers", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "modifierable_id"
    t.string   "modifierable_type", limit: 255
    t.uuid     "entityable_id"
    t.string   "entityable_type",   limit: 255
    t.integer  "sort_order"
    t.string   "category",          limit: 255
    t.string   "item",              limit: 255
    t.integer  "value"
    t.string   "dice",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "entitybuilder_modifiers", ["entityable_id", "entityable_type"], name: "eb_modifier_entity_id_and_type", using: :btree
  add_index "entitybuilder_modifiers", ["modifierable_id", "modifierable_type"], name: "eb_modifier_id_and_type", using: :btree

  create_table "entitybuilder_movements", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "movementable_id"
    t.string   "movementable_type", limit: 255
    t.integer  "sort_order"
    t.string   "name",              limit: 255, null: false
    t.text     "description"
    t.integer  "distance"
    t.string   "measurement",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "entitybuilder_movements", ["movementable_id", "movementable_type"], name: "eb_movement_id_and_type", using: :btree
  add_index "entitybuilder_movements", ["movementable_id", "name"], name: "eb_movement_name", unique: true, using: :btree

  create_table "entitybuilder_saving_throws", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "saving_throwable_id"
    t.string   "saving_throwable_type", limit: 255
    t.integer  "sort_order"
    t.string   "name",                  limit: 255
    t.text     "description"
    t.integer  "base"
    t.integer  "bonus"
    t.string   "ability_score",         limit: 255
    t.integer  "misc_modifier"
    t.string   "dice",                  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "proficient"
  end

  add_index "entitybuilder_saving_throws", ["saving_throwable_id", "name"], name: "eb_saving_throw_name", unique: true, using: :btree
  add_index "entitybuilder_saving_throws", ["saving_throwable_id", "saving_throwable_type"], name: "eb_saving_throw_id_and_type", using: :btree

  create_table "entitybuilder_skills", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "skillable_id"
    t.string   "skillable_type", limit: 255
    t.integer  "sort_order"
    t.string   "name",           limit: 255, null: false
    t.text     "description"
    t.integer  "bonus"
    t.boolean  "class_skill"
    t.string   "ability_score",  limit: 255
    t.integer  "ranks"
    t.integer  "misc_modifier"
    t.string   "dice",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "proficient"
  end

  add_index "entitybuilder_skills", ["skillable_id", "name"], name: "eb_skill_name", unique: true, using: :btree
  add_index "entitybuilder_skills", ["skillable_id", "skillable_type"], name: "eb_skill_id_and_type", using: :btree

  create_table "entitybuilder_spells", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "name",              limit: 255, null: false
    t.string   "short_description", limit: 255
    t.text     "full_description"
    t.string   "school",            limit: 255
    t.integer  "level"
    t.string   "casting_time",      limit: 255
    t.string   "components",        limit: 255
    t.string   "range",             limit: 255
    t.string   "effect",            limit: 255
    t.string   "target",            limit: 255
    t.string   "area",              limit: 255
    t.string   "duration",          limit: 255
    t.string   "saving_throw",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.uuid     "resident_id"
    t.string   "core_rules",        limit: 255
  end

  add_index "entitybuilder_spells", ["resident_id"], name: "index_entitybuilder_spells_on_resident_id", using: :btree

  create_table "entitybuilder_trackables", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "trackableable_id"
    t.string   "trackableable_type", limit: 255
    t.integer  "sort_order"
    t.string   "name",               limit: 255, null: false
    t.text     "description"
    t.integer  "minimum"
    t.integer  "maximum"
    t.integer  "current"
    t.integer  "temporary"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "entitybuilder_trackables", ["trackableable_id", "name"], name: "eb_trackable_name", unique: true, using: :btree
  add_index "entitybuilder_trackables", ["trackableable_id", "trackableable_type"], name: "eb_trackable_id_and_type", using: :btree

  create_table "tester_blorghs", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tester_characters", force: :cascade do |t|
    t.uuid     "resident_id"
    t.string   "name",              limit: 255
    t.string   "privacy",           limit: 255
    t.string   "sheet_privacy",     limit: 255
    t.string   "core_rules",        limit: 255
    t.string   "short_description", limit: 255
    t.text     "full_description"
    t.text     "notes"
    t.string   "sheet_font",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
