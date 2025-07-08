# frozen_string_literal: false

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

ActiveRecord::Schema.define(version: 20161111120001) do

  # These are extensions that must be enabled in order to support this database
  # enable_extension "uuid-ossp"
  # enable_extension "plpgsql"
  # enable_extension "pg_stat_statements"

  create_table "activeplay_notables", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "name"
    t.integer  "sort_order"
    t.uuid     "virtual_table_id"
    t.uuid     "entity_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["entity_id"], name: "index_activeplay_notables_on_entity_id", using: :btree
    t.index ["virtual_table_id"], name: "index_activeplay_notables_on_virtual_table_id", using: :btree
  end

  create_table "activeplay_virtual_tables", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "campaign_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["campaign_id"], name: "index_activeplay_virtual_tables_on_campaign_id", unique: true, using: :btree
  end

  create_table "admins", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.integer  "failed_attempts",                    default: 0,  null: false
    t.string   "unlock_token",           limit: 255
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["email"], name: "index_admins_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree
    t.index ["unlock_token"], name: "index_admins_on_unlock_token", unique: true, using: :btree
  end

  create_table "affiliations", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "resident_id",              null: false
    t.uuid     "affiliate_id",             null: false
    t.string   "status",       limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["affiliate_id", "resident_id"], name: "index_affiliations_on_affiliate_id_and_resident_id", using: :btree
    t.index ["affiliate_id"], name: "index_affiliations_on_affiliate_id", using: :btree
    t.index ["resident_id"], name: "index_affiliations_on_resident_id", using: :btree
  end

  create_table "beta_invites", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "email",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["email"], name: "index_beta_invites_on_email", unique: true, using: :btree
  end

  create_table "billing_events", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "user_id",            null: false
    t.text     "stripe_event_token", null: false
    t.datetime "event_date"
    t.text     "event_type"
    t.json     "event_data"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["stripe_event_token"], name: "index_billing_events_on_stripe_event_token", unique: true, using: :btree
    t.index ["user_id"], name: "index_billing_events_on_user_id", using: :btree
  end

  create_table "billing_plans", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "name",              null: false
    t.string   "stripe_plan_token"
    t.string   "interval"
    t.integer  "interval_count"
    t.string   "currency"
    t.integer  "amount"
    t.string   "description"
    t.boolean  "active"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "billing_subscriptions", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "user_id",                   null: false
    t.uuid     "plan_id"
    t.string   "stripe_subscription_token", null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.index ["stripe_subscription_token"], name: "index_billing_subscriptions_on_stripe_subscription_token", unique: true, using: :btree
    t.index ["user_id"], name: "index_billing_subscriptions_on_user_id", unique: true, using: :btree
  end

  create_table "campaignmanager_campaigns", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "resident_id",                   null: false
    t.string   "name",              limit: 255, null: false
    t.string   "slug",              limit: 255, null: false
    t.string   "page_label",        limit: 255
    t.string   "privacy",           limit: 255, null: false
    t.string   "short_description", limit: 255
    t.text     "full_description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.uuid     "district_id"
    t.uuid     "adventure_id"
    t.string   "core_rules"
    t.index ["adventure_id"], name: "index_campaignmanager_campaigns_on_adventure_id", using: :btree
    t.index ["district_id"], name: "index_campaignmanager_campaigns_on_district_id", using: :btree
    t.index ["resident_id"], name: "index_campaignmanager_campaigns_on_resident_id", using: :btree
  end

  create_table "campaignmanager_features", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
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
    t.index ["featureable_id", "featureable_type"], name: "index_campaignmanager_features_id_and_type", using: :btree
  end

  create_table "campaignmanager_notables", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "notableable_id"
    t.string   "notableable_type"
    t.uuid     "entity_id"
    t.string   "name"
    t.integer  "sort_order"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["entity_id"], name: "index_campaignmanager_notables_on_entity_id", using: :btree
    t.index ["notableable_id", "notableable_type"], name: "cm_notable_id_and_type", using: :btree
  end

  create_table "campaignmanager_pages", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "type",              limit: 255, null: false
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
    t.date     "page_date"
    t.index ["campaign_id"], name: "index_campaignmanager_pages_on_campaign_id", using: :btree
    t.index ["parent_id"], name: "index_campaignmanager_pages_on_parent_id", using: :btree
  end

  create_table "campaignmanager_players", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "campaign_id"
    t.uuid     "affiliation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["campaign_id", "affiliation_id"], name: "index_campaignmanager_players_campaign_and_affiliate", unique: true, using: :btree
  end

  create_table "campaignmanager_sections", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
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
    t.index ["sectionable_id", "sectionable_type"], name: "index_campaignmanager_sections_id_and_type", using: :btree
  end

  create_table "entitybuilder_ability_scores", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "entity_id"
    t.integer  "sort_order"
    t.string   "name",        limit: 255, null: false
    t.text     "description"
    t.integer  "base"
    t.integer  "score"
    t.integer  "modifier"
    t.string   "dice",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["entity_id"], name: "index_entitybuilder_ability_scores_on_entity_id", using: :btree
  end

  create_table "entitybuilder_attacks", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "entity_id"
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
    t.index ["entity_id"], name: "index_entitybuilder_attacks_on_entity_id", using: :btree
  end

  create_table "entitybuilder_base_values", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "entity_id"
    t.integer  "sort_order"
    t.string   "name",        limit: 255, null: false
    t.text     "description"
    t.integer  "value"
    t.string   "dice",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["entity_id"], name: "index_entitybuilder_base_values_on_entity_id", using: :btree
  end

  create_table "entitybuilder_campaign_joins", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "entity_id"
    t.uuid     "campaign_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["entity_id"], name: "index_entitybuilder_campaign_joins_on_entity_id", using: :btree
  end

  create_table "entitybuilder_caster_levels", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "entity_id"
    t.integer  "sort_order"
    t.string   "caster_class",  limit: 255
    t.integer  "level"
    t.integer  "per_day"
    t.integer  "bonus_per_day"
    t.integer  "base_dc"
    t.string   "ability_score", limit: 255
    t.integer  "save_dc"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "proficient"
    t.index ["entity_id"], name: "index_entitybuilder_caster_levels_on_entity_id", using: :btree
  end

  create_table "entitybuilder_class_levels", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "entity_id"
    t.integer  "sort_order"
    t.string   "name",        limit: 255, null: false
    t.text     "description"
    t.integer  "level"
    t.string   "hit_dice",    limit: 255
    t.integer  "hit_points"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["entity_id"], name: "index_entitybuilder_class_levels_on_entity_id", using: :btree
  end

  create_table "entitybuilder_currencies", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "entity_id"
    t.integer  "sort_order"
    t.string   "name",        limit: 255
    t.text     "description"
    t.decimal  "weight"
    t.bigint   "quantity"
    t.boolean  "carried"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["entity_id"], name: "index_entitybuilder_currencies_on_entity_id", using: :btree
  end

  create_table "entitybuilder_defenses", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "entity_id"
    t.integer  "sort_order"
    t.string   "name",          limit: 255, null: false
    t.text     "description"
    t.integer  "base"
    t.integer  "bonus"
    t.string   "ability_score", limit: 255
    t.integer  "misc_modifier"
    t.string   "dice",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["entity_id"], name: "index_entitybuilder_defenses_on_entity_id", using: :btree
  end

  create_table "entitybuilder_descriptors", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "entity_id"
    t.integer  "sort_order"
    t.string   "name",        limit: 255,                 null: false
    t.string   "description", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_private",              default: false
    t.index ["entity_id"], name: "index_entitybuilder_descriptors_on_entity_id", using: :btree
  end

  create_table "entitybuilder_entities", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "type",                              null: false
    t.uuid     "resident_id"
    t.string   "name"
    t.string   "core_rules"
    t.string   "privacy"
    t.string   "sheet_privacy"
    t.string   "short_description"
    t.text     "full_description"
    t.text     "introduction"
    t.text     "notes"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "publisher"
    t.string   "source"
    t.boolean  "is_3pp",            default: false
    t.text     "tags",              default: [],                 array: true
    t.index ["resident_id"], name: "index_entitybuilder_entities_on_resident_id", using: :btree
    t.index ["tags"], name: "index_entitybuilder_entities_on_tags", using: :gin
    t.index ["type"], name: "index_entitybuilder_entities_on_type", using: :btree
  end

  create_table "entitybuilder_inventory_items", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "entity_id"
    t.integer  "sort_order"
    t.uuid     "item_id"
    t.integer  "quantity"
    t.boolean  "equipped"
    t.boolean  "carried"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "detail"
    t.index ["entity_id"], name: "index_entitybuilder_inventory_items_on_entity_id", using: :btree
    t.index ["item_id"], name: "index_entitybuilder_inventory_items_on_item_id", using: :btree
  end

  create_table "entitybuilder_known_abilities", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "entity_id"
    t.integer  "sort_order"
    t.uuid     "ability_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "detail"
    t.index ["ability_id"], name: "index_entitybuilder_known_abilities_on_ability_id", using: :btree
    t.index ["entity_id"], name: "index_entitybuilder_known_abilities_on_entity_id", using: :btree
  end

  create_table "entitybuilder_known_feats", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "entity_id"
    t.integer  "sort_order"
    t.uuid     "feat_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "detail"
    t.index ["entity_id"], name: "index_entitybuilder_known_feats_on_entity_id", using: :btree
    t.index ["feat_id"], name: "index_entitybuilder_known_feats_on_feat_id", using: :btree
  end

  create_table "entitybuilder_known_spells", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "entity_id"
    t.integer  "sort_order"
    t.uuid     "spell_id"
    t.boolean  "prepared"
    t.boolean  "used"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "spell_class"
    t.integer  "level"
    t.string   "detail"
    t.boolean  "at_will",     default: false
    t.index ["entity_id"], name: "index_entitybuilder_known_spells_on_entity_id", using: :btree
    t.index ["spell_id"], name: "index_entitybuilder_known_spells_on_spell_id", using: :btree
  end

  create_table "entitybuilder_linked_rules", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "entity_id"
    t.uuid     "rule_id"
    t.integer  "sort_order"
    t.string   "detail"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entity_id"], name: "index_entitybuilder_linked_rules_on_entity_id", using: :btree
    t.index ["rule_id"], name: "index_entitybuilder_linked_rules_on_rule_id", using: :btree
  end

  create_table "entitybuilder_modifiers", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "modifierable_id"
    t.string   "modifierable_type", limit: 255
    t.uuid     "entity_id"
    t.integer  "sort_order"
    t.string   "category",          limit: 255
    t.string   "item",              limit: 255
    t.integer  "value"
    t.string   "dice",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "original_mod_type"
    t.index ["entity_id"], name: "index_entitybuilder_modifiers_on_entity_id", using: :btree
    t.index ["modifierable_id", "modifierable_type"], name: "eb_modifier_id_and_type", using: :btree
  end

  create_table "entitybuilder_movements", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "entity_id"
    t.integer  "sort_order"
    t.string   "name",          limit: 255, null: false
    t.integer  "base"
    t.string   "description",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "bonus"
    t.string   "ability_score", limit: 255
    t.integer  "misc_modifier"
    t.string   "dice",          limit: 255
    t.index ["entity_id"], name: "index_entitybuilder_movements_on_entity_id", using: :btree
  end

  create_table "entitybuilder_notables", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "notableable_id"
    t.string   "notableable_type"
    t.uuid     "entity_id"
    t.string   "name"
    t.integer  "sort_order"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["entity_id"], name: "index_entitybuilder_notables_on_entity_id", using: :btree
    t.index ["notableable_id", "notableable_type"], name: "eb_notable_id_and_type", using: :btree
  end

  create_table "entitybuilder_saving_throws", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "entity_id"
    t.integer  "sort_order"
    t.string   "name",          limit: 255
    t.text     "description"
    t.integer  "base"
    t.integer  "bonus"
    t.string   "ability_score", limit: 255
    t.integer  "misc_modifier"
    t.string   "dice",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "proficient"
    t.index ["entity_id"], name: "index_entitybuilder_saving_throws_on_entity_id", using: :btree
  end

  create_table "entitybuilder_skills", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "entity_id"
    t.integer  "sort_order"
    t.string   "name",          limit: 255, null: false
    t.text     "description"
    t.integer  "bonus"
    t.boolean  "class_skill"
    t.string   "ability_score", limit: 255
    t.integer  "ranks"
    t.integer  "misc_modifier"
    t.string   "dice",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "proficient"
    t.index ["entity_id"], name: "index_entitybuilder_skills_on_entity_id", using: :btree
  end

  create_table "entitybuilder_trackables", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "entity_id"
    t.integer  "sort_order"
    t.string   "name",        limit: 255, null: false
    t.text     "description"
    t.integer  "minimum"
    t.integer  "maximum"
    t.integer  "current"
    t.integer  "temporary"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["entity_id"], name: "index_entitybuilder_trackables_on_entity_id", using: :btree
  end

  create_table "entitybuilder_traits", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "entity_id"
    t.integer  "sort_order"
    t.string   "name",              null: false
    t.string   "short_description"
    t.text     "full_description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "detail"
    t.index ["entity_id"], name: "index_entitybuilder_traits_on_entity_id", using: :btree
  end

  create_table "gallery_image_joins", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "image_id",                   null: false
    t.uuid     "imageable_id",               null: false
    t.string   "imageable_type", limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["imageable_id", "imageable_type"], name: "index_gallery_image_joins_on_imageable_id_and_imageable_type", using: :btree
  end

  create_table "gallery_images", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "type",              limit: 255, null: false
    t.uuid     "resident_id"
    t.string   "name",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "file_file_name",    limit: 255
    t.string   "file_content_type", limit: 255
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.boolean  "file_processing"
    t.index ["resident_id"], name: "index_gallery_images_on_resident_id", using: :btree
  end

  create_table "messages", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "sender_id",                                     null: false
    t.uuid     "recipient_id"
    t.boolean  "sender_deleted",                default: false
    t.boolean  "recipient_deleted",             default: false
    t.string   "subject",           limit: 255,                 null: false
    t.text     "body"
    t.datetime "read_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["recipient_id"], name: "index_messages_on_recipient_id", using: :btree
    t.index ["sender_id"], name: "index_messages_on_sender_id", using: :btree
  end

  create_table "residents", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "user_id",                       null: false
    t.string   "name",              limit: 255, null: false
    t.string   "slug",              limit: 255, null: false
    t.string   "short_description", limit: 255
    t.text     "full_description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title"
    t.text     "badges"
    t.index ["slug"], name: "index_residents_on_slug", unique: true, using: :btree
    t.index ["user_id"], name: "index_residents_on_user_id", unique: true, using: :btree
  end

  create_table "rulebuilder_abilities", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "type",                              null: false
    t.uuid     "resident_id"
    t.string   "core_rules"
    t.string   "name"
    t.string   "short_description"
    t.text     "full_description"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.uuid     "parent_id"
    t.string   "publisher"
    t.string   "source"
    t.boolean  "is_3pp",            default: false
    t.text     "tags",              default: [],                 array: true
    t.index ["parent_id"], name: "index_rulebuilder_abilities_on_parent_id", using: :btree
    t.index ["resident_id"], name: "index_rulebuilder_abilities_on_resident_id", using: :btree
    t.index ["tags"], name: "index_rulebuilder_abilities_on_tags", using: :gin
    t.index ["type"], name: "index_rulebuilder_abilities_on_type", using: :btree
  end

  create_table "rulebuilder_feats", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "type",                              null: false
    t.uuid     "resident_id"
    t.string   "core_rules"
    t.string   "name"
    t.string   "short_description"
    t.text     "full_description"
    t.string   "prerequisites"
    t.text     "benefit"
    t.text     "normal"
    t.text     "special"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.text     "categories",        default: [],                 array: true
    t.uuid     "parent_id"
    t.string   "publisher"
    t.string   "source"
    t.boolean  "is_3pp",            default: false
    t.text     "tags",              default: [],                 array: true
    t.index ["categories"], name: "index_rulebuilder_feats_on_categories", using: :gin
    t.index ["parent_id"], name: "index_rulebuilder_feats_on_parent_id", using: :btree
    t.index ["resident_id"], name: "index_rulebuilder_feats_on_resident_id", using: :btree
    t.index ["tags"], name: "index_rulebuilder_feats_on_tags", using: :gin
    t.index ["type"], name: "index_rulebuilder_feats_on_type", using: :btree
  end

  create_table "rulebuilder_items", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "type",                              null: false
    t.uuid     "resident_id"
    t.string   "core_rules"
    t.string   "name"
    t.string   "short_description"
    t.text     "full_description"
    t.text     "category"
    t.decimal  "weight"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.uuid     "parent_id"
    t.string   "publisher"
    t.string   "source"
    t.boolean  "is_3pp",            default: false
    t.text     "tags",              default: [],                 array: true
    t.index ["parent_id"], name: "index_rulebuilder_items_on_parent_id", using: :btree
    t.index ["resident_id"], name: "index_rulebuilder_items_on_resident_id", using: :btree
    t.index ["tags"], name: "index_rulebuilder_items_on_tags", using: :gin
    t.index ["type"], name: "index_rulebuilder_items_on_type", using: :btree
  end

  create_table "rulebuilder_rules", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "type",                           null: false
    t.uuid     "resident_id"
    t.uuid     "parent_id"
    t.string   "core_rules"
    t.string   "rule_type"
    t.boolean  "is_shared"
    t.string   "name"
    t.string   "short_description"
    t.text     "full_description"
    t.string   "publisher"
    t.string   "source"
    t.boolean  "is_3pp"
    t.text     "tags",              default: [],              array: true
    t.text     "categories",        default: [],              array: true
    t.string   "prerequisites"
    t.text     "benefit"
    t.text     "normal"
    t.text     "special"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.index ["categories"], name: "index_rulebuilder_rules_on_categories", using: :gin
    t.index ["parent_id"], name: "index_rulebuilder_rules_on_parent_id", using: :btree
    t.index ["resident_id"], name: "index_rulebuilder_rules_on_resident_id", using: :btree
    t.index ["tags"], name: "index_rulebuilder_rules_on_tags", using: :gin
    t.index ["type"], name: "index_rulebuilder_rules_on_type", using: :btree
  end

  create_table "rulebuilder_spells", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "type",                              null: false
    t.uuid     "resident_id"
    t.string   "core_rules"
    t.string   "name"
    t.string   "short_description"
    t.text     "full_description"
    t.string   "school"
    t.string   "casting_time"
    t.string   "components"
    t.string   "range"
    t.string   "effect"
    t.string   "target"
    t.string   "area"
    t.string   "duration"
    t.string   "saving_throw"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "spell_resistance"
    t.text     "levels",            default: [],                 array: true
    t.uuid     "parent_id"
    t.string   "publisher"
    t.string   "source"
    t.boolean  "is_3pp",            default: false
    t.text     "tags",              default: [],                 array: true
    t.index ["levels"], name: "index_rulebuilder_spells_on_levels", using: :gin
    t.index ["parent_id"], name: "index_rulebuilder_spells_on_parent_id", using: :btree
    t.index ["resident_id"], name: "index_rulebuilder_spells_on_resident_id", using: :btree
    t.index ["tags"], name: "index_rulebuilder_spells_on_tags", using: :gin
    t.index ["type"], name: "index_rulebuilder_spells_on_type", using: :btree
  end

  create_table "storybuilder_adventures", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "resident_id"
    t.uuid     "parent_id"
    t.string   "name",              limit: 255, null: false
    t.string   "slug",              limit: 255, null: false
    t.string   "page_label",        limit: 255
    t.string   "privacy",           limit: 255, null: false
    t.string   "short_description", limit: 255
    t.text     "full_description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.string   "core_rules"
    t.index ["parent_id"], name: "index_storybuilder_adventures_on_parent_id", using: :btree
    t.index ["resident_id"], name: "index_storybuilder_adventures_on_resident_id", using: :btree
  end

  create_table "storybuilder_features", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
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
    t.index ["featureable_id", "featureable_type"], name: "index_storybuilder_features_id_and_type", using: :btree
  end

  create_table "storybuilder_menu_item_joins", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "menu_item_id",                        null: false
    t.uuid     "menu_item_joinable_id",               null: false
    t.string   "menu_item_joinable_type", limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["menu_item_id"], name: "index_storybuilder_menu_item_joins_on_menu_item_id", using: :btree
    t.index ["menu_item_joinable_id", "menu_item_joinable_type"], name: "sb_menu_item_join_id_and_type", using: :btree
  end

  create_table "storybuilder_menu_items", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "menu_itemable_id"
    t.string   "menu_itemable_type", limit: 255
    t.integer  "sort_order"
    t.string   "item_label",         limit: 255
    t.string   "item_link",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["menu_itemable_id", "menu_itemable_type"], name: "sb_menu_item_id_and_type", using: :btree
  end

  create_table "storybuilder_notables", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "notableable_id"
    t.string   "notableable_type"
    t.uuid     "entity_id"
    t.string   "name"
    t.integer  "sort_order"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.index ["entity_id"], name: "index_storybuilder_notables_on_entity_id", using: :btree
    t.index ["notableable_id", "notableable_type"], name: "sb_notable_id_and_type", using: :btree
  end

  create_table "storybuilder_pages", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "type",              limit: 255
    t.uuid     "parent_id"
    t.string   "name",              limit: 255
    t.string   "slug",              limit: 255
    t.string   "page_label",        limit: 255
    t.string   "privacy",           limit: 255
    t.string   "short_description", limit: 255
    t.text     "full_description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.uuid     "adventure_id"
    t.text     "tags",                          default: [],                 array: true
    t.integer  "sort_weight",                   default: 1000,  null: false
    t.boolean  "player_handout",                default: false
    t.index ["adventure_id"], name: "index_storybuilder_pages_on_adventure_id", using: :btree
    t.index ["parent_id"], name: "index_storybuilder_pages_on_parent_id", using: :btree
    t.index ["tags"], name: "index_storybuilder_pages_on_tags", using: :gin
  end

  create_table "storybuilder_sections", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
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
    t.index ["sectionable_id", "sectionable_type"], name: "index_storybuilder_sections_id_and_type", using: :btree
  end

  create_table "support_core_faqs", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "faq_id",     null: false
    t.string   "core_item",  null: false
    t.boolean  "active",     null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "support_faqs", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "topic",      limit: 255
    t.string   "question",   limit: 255, null: false
    t.text     "answer"
    t.boolean  "active",                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",      null: false
    t.string   "encrypted_password",     limit: 255, default: "",      null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,       null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 255
    t.integer  "failed_attempts",                    default: 0,       null: false
    t.string   "unlock_token",           limit: 255
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",                 limit: 255, default: "trial", null: false
    t.string   "stripe_customer_token"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["status"], name: "index_users_on_status", using: :btree
    t.index ["stripe_customer_token"], name: "index_users_on_stripe_customer_token", using: :btree
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree
  end

  create_table "worldbuilder_contributors", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "district_id",    null: false
    t.uuid     "affiliation_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["district_id", "affiliation_id"], name: "index_worldbuilder_contributers_district_and_affiliate", unique: true, using: :btree
  end

  create_table "worldbuilder_districts", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "resident_id"
    t.string   "name",              limit: 255, null: false
    t.string   "slug",              limit: 255, null: false
    t.string   "short_description", limit: 255
    t.text     "full_description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "privacy",           limit: 255
    t.string   "page_label",        limit: 255
    t.index ["resident_id"], name: "index_worldbuilder_districts_on_resident_id", using: :btree
    t.index ["slug"], name: "index_worldbuilder_districts_on_slug", unique: true, using: :btree
  end

  create_table "worldbuilder_features", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
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
    t.index ["featureable_id", "featureable_type"], name: "index_worldbuilder_features_id_and_type", using: :btree
  end

  create_table "worldbuilder_menu_item_joins", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "menu_item_id",                        null: false
    t.uuid     "menu_item_joinable_id",               null: false
    t.string   "menu_item_joinable_type", limit: 255, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["menu_item_id"], name: "index_worldbuilder_menu_item_joins_on_menu_item_id", using: :btree
    t.index ["menu_item_joinable_id", "menu_item_joinable_type"], name: "wb_menu_item_joins_id_and_type", using: :btree
  end

  create_table "worldbuilder_menu_items", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.uuid     "menu_itemable_id"
    t.string   "menu_itemable_type", limit: 255
    t.integer  "sort_order"
    t.string   "item_label",         limit: 255
    t.string   "item_link",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "worldbuilder_pages", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
    t.string   "type",              limit: 255
    t.uuid     "district_id"
    t.uuid     "parent_id"
    t.string   "name",              limit: 255
    t.string   "slug",              limit: 255
    t.string   "page_label",        limit: 255
    t.string   "short_description", limit: 255
    t.text     "full_description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "tags",                          default: [],                array: true
    t.integer  "sort_weight",                   default: 1000, null: false
    t.index ["district_id", "slug"], name: "index_worldbuilder_pages_on_district_id_and_slug", using: :btree
    t.index ["parent_id"], name: "index_worldbuilder_pages_on_parent_id", using: :btree
    t.index ["tags"], name: "index_worldbuilder_pages_on_tags", using: :gin
  end

  create_table "worldbuilder_sections", id: :uuid, default: -> { "uuid_generate_v4()" }, force: :cascade do |t|
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
    t.index ["sectionable_id", "sectionable_type"], name: "index_worldbuilder_sections_id_and_type", using: :btree
  end

end
