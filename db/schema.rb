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

ActiveRecord::Schema.define(version: 2026_06_22_195600) do

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.string "record_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activeplay_notables", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "name"
    t.integer "sort_order"
    t.text "virtual_table_id"
    t.text "entity_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entity_id"], name: "index_activeplay_notables_on_entity_id"
    t.index ["virtual_table_id"], name: "index_activeplay_notables_on_virtual_table_id"
  end

  create_table "activeplay_virtual_tables", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "campaign_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id"], name: "index_activeplay_virtual_tables_on_campaign_id", unique: true
  end

  create_table "admins", force: :cascade do |t|
    t.text "email", default: "", null: false
    t.text "encrypted_password", default: "", null: false
    t.text "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.text "current_sign_in_ip"
    t.text "last_sign_in_ip"
    t.integer "failed_attempts", default: 0, null: false
    t.text "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_admins_on_unlock_token", unique: true
  end

  create_table "affiliations", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "resident_id", null: false
    t.text "affiliate_id", null: false
    t.text "status", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["affiliate_id", "resident_id"], name: "index_affiliations_on_affiliate_id_and_resident_id"
    t.index ["affiliate_id"], name: "index_affiliations_on_affiliate_id"
    t.index ["resident_id"], name: "index_affiliations_on_resident_id"
  end

  create_table "beta_invites", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["email"], name: "index_beta_invites_on_email", unique: true
  end

  create_table "billing_events", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "user_id", null: false
    t.text "stripe_event_token", null: false
    t.datetime "event_date"
    t.text "event_type"
    t.text "event_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stripe_event_token"], name: "index_billing_events_on_stripe_event_token", unique: true
    t.index ["user_id"], name: "index_billing_events_on_user_id"
  end

  create_table "billing_plans", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "name", null: false
    t.text "stripe_plan_token"
    t.text "interval"
    t.integer "interval_count"
    t.text "currency"
    t.integer "amount"
    t.text "description"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "billing_subscriptions", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "user_id", null: false
    t.text "plan_id"
    t.text "stripe_subscription_token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["stripe_subscription_token"], name: "index_billing_subscriptions_on_stripe_subscription_token", unique: true
    t.index ["user_id"], name: "index_billing_subscriptions_on_user_id", unique: true
  end

  create_table "campaignmanager_campaign_adventure_joins", id: :string, force: :cascade do |t|
    t.string "campaign_id", null: false
    t.string "adventure_id", null: false
    t.boolean "active", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["campaign_id", "active"], name: "idx_cm_campaign_adventure_joins_active"
    t.index ["campaign_id", "adventure_id"], name: "idx_cm_campaign_adventure_joins_unique", unique: true
  end

  create_table "campaignmanager_campaigns", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "resident_id", null: false
    t.text "name", null: false
    t.text "slug", null: false
    t.text "page_label"
    t.text "privacy", null: false
    t.text "short_description"
    t.text "full_description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "district_id"
    t.text "core_rules"
    t.index ["district_id"], name: "index_campaignmanager_campaigns_on_district_id"
    t.index ["resident_id"], name: "index_campaignmanager_campaigns_on_resident_id"
  end

  create_table "campaignmanager_features", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "featureable_id"
    t.text "featureable_type"
    t.integer "sort_order"
    t.text "feature_label"
    t.text "feature_text"
    t.text "feature_type"
    t.text "record_type"
    t.text "search_tags"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["featureable_id", "featureable_type"], name: "index_campaignmanager_features_id_and_type"
  end

  create_table "campaignmanager_notables", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "notableable_id"
    t.text "notableable_type"
    t.text "entity_id"
    t.text "name"
    t.integer "sort_order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entity_id"], name: "index_campaignmanager_notables_on_entity_id"
    t.index ["notableable_id", "notableable_type"], name: "cm_notable_id_and_type"
  end

  create_table "campaignmanager_pages", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "type", null: false
    t.text "campaign_id"
    t.text "parent_id"
    t.text "name"
    t.text "slug"
    t.text "page_label"
    t.text "privacy"
    t.text "short_description"
    t.text "full_description", limit: 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date "page_date"
    t.index ["campaign_id"], name: "index_campaignmanager_pages_on_campaign_id"
    t.index ["parent_id"], name: "index_campaignmanager_pages_on_parent_id"
  end

  create_table "campaignmanager_players", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "campaign_id"
    t.text "affiliation_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["campaign_id", "affiliation_id"], name: "index_campaignmanager_players_campaign_and_affiliate", unique: true
  end

  create_table "campaignmanager_sections", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "sectionable_id"
    t.text "sectionable_type"
    t.integer "sort_order"
    t.text "header"
    t.text "content"
    t.text "section_type"
    t.text "section_style"
    t.text "record_type"
    t.text "search_tags"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["sectionable_id", "sectionable_type"], name: "index_campaignmanager_sections_id_and_type"
  end

  create_table "entitybuilder_ability_scores", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "entity_id"
    t.integer "sort_order"
    t.text "name", null: false
    t.text "description"
    t.integer "base"
    t.integer "score"
    t.integer "modifier"
    t.text "dice"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["entity_id"], name: "index_entitybuilder_ability_scores_on_entity_id"
  end

  create_table "entitybuilder_attacks", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "entity_id"
    t.integer "sort_order"
    t.text "name", null: false
    t.text "description"
    t.text "attack_type"
    t.text "attack_range"
    t.text "attack_ability_score"
    t.text "attack_dice"
    t.integer "attack_bonus"
    t.integer "attack_misc_modifier"
    t.text "damage_ability_score"
    t.text "damage_dice"
    t.integer "damage_bonus"
    t.integer "damage_misc_modifier"
    t.text "critical_range"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "proficient"
    t.text "damage_type"
    t.text "critical_damage_ability_score"
    t.text "critical_damage_dice"
    t.integer "critical_damage_bonus"
    t.integer "critical_damage_misc_modifier"
    t.text "special_damage_ability_score"
    t.text "special_damage_dice"
    t.integer "special_damage_bonus"
    t.integer "special_damage_misc_modifier"
    t.text "special_damage_name"
    t.index ["entity_id"], name: "index_entitybuilder_attacks_on_entity_id"
  end

  create_table "entitybuilder_base_values", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "entity_id"
    t.integer "sort_order"
    t.text "name", null: false
    t.text "description"
    t.integer "value"
    t.text "dice"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["entity_id"], name: "index_entitybuilder_base_values_on_entity_id"
  end

  create_table "entitybuilder_campaign_joins", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "entity_id"
    t.text "campaign_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["entity_id"], name: "index_entitybuilder_campaign_joins_on_entity_id"
  end

  create_table "entitybuilder_caster_levels", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "entity_id"
    t.integer "sort_order"
    t.text "caster_class"
    t.integer "level"
    t.integer "per_day"
    t.integer "bonus_per_day"
    t.integer "base_dc"
    t.text "ability_score"
    t.integer "save_dc"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "proficient"
    t.index ["entity_id"], name: "index_entitybuilder_caster_levels_on_entity_id"
  end

  create_table "entitybuilder_class_levels", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "entity_id"
    t.integer "sort_order"
    t.text "name", null: false
    t.text "description"
    t.integer "level"
    t.text "hit_dice"
    t.integer "hit_points"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["entity_id"], name: "index_entitybuilder_class_levels_on_entity_id"
  end

  create_table "entitybuilder_currencies", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "entity_id"
    t.integer "sort_order"
    t.text "name"
    t.text "description"
    t.float "weight"
    t.bigint "quantity"
    t.boolean "carried"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["entity_id"], name: "index_entitybuilder_currencies_on_entity_id"
  end

  create_table "entitybuilder_defenses", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "entity_id"
    t.integer "sort_order"
    t.text "name", null: false
    t.text "description"
    t.integer "base"
    t.integer "bonus"
    t.text "ability_score"
    t.integer "misc_modifier"
    t.text "dice"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["entity_id"], name: "index_entitybuilder_defenses_on_entity_id"
  end

  create_table "entitybuilder_descriptors", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "entity_id"
    t.integer "sort_order"
    t.text "name", null: false
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "is_private", default: false
    t.index ["entity_id"], name: "index_entitybuilder_descriptors_on_entity_id"
  end

  create_table "entitybuilder_entities", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "type", null: false
    t.text "resident_id"
    t.text "name"
    t.text "core_rules"
    t.text "privacy"
    t.text "sheet_privacy"
    t.text "short_description"
    t.text "full_description"
    t.text "introduction"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "publisher"
    t.text "source"
    t.boolean "is_3pp", default: false
    t.text "tags", default: "[]"
    t.index ["resident_id"], name: "index_entitybuilder_entities_on_resident_id"
    t.index ["tags"], name: "index_entitybuilder_entities_on_tags"
    t.index ["type"], name: "index_entitybuilder_entities_on_type"
  end

  create_table "entitybuilder_inventory_items", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "entity_id"
    t.integer "sort_order"
    t.text "item_id"
    t.integer "quantity"
    t.boolean "equipped"
    t.boolean "carried"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "detail"
    t.index ["entity_id"], name: "index_entitybuilder_inventory_items_on_entity_id"
    t.index ["item_id"], name: "index_entitybuilder_inventory_items_on_item_id"
  end

  create_table "entitybuilder_known_abilities", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "entity_id"
    t.integer "sort_order"
    t.text "ability_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "detail"
    t.index ["ability_id"], name: "index_entitybuilder_known_abilities_on_ability_id"
    t.index ["entity_id"], name: "index_entitybuilder_known_abilities_on_entity_id"
  end

  create_table "entitybuilder_known_feats", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "entity_id"
    t.integer "sort_order"
    t.text "feat_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "detail"
    t.index ["entity_id"], name: "index_entitybuilder_known_feats_on_entity_id"
    t.index ["feat_id"], name: "index_entitybuilder_known_feats_on_feat_id"
  end

  create_table "entitybuilder_known_spells", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "entity_id"
    t.integer "sort_order"
    t.text "spell_id"
    t.boolean "prepared"
    t.boolean "used"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "spell_class"
    t.integer "level"
    t.text "detail"
    t.boolean "at_will", default: false
    t.index ["entity_id"], name: "index_entitybuilder_known_spells_on_entity_id"
    t.index ["spell_id"], name: "index_entitybuilder_known_spells_on_spell_id"
  end

  create_table "entitybuilder_linked_rules", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "entity_id"
    t.text "rule_id"
    t.integer "sort_order"
    t.text "detail"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entity_id"], name: "index_entitybuilder_linked_rules_on_entity_id"
    t.index ["rule_id"], name: "index_entitybuilder_linked_rules_on_rule_id"
  end

  create_table "entitybuilder_modifiers", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "modifierable_id"
    t.text "modifierable_type"
    t.text "entity_id"
    t.integer "sort_order"
    t.text "category"
    t.text "item"
    t.integer "value"
    t.text "dice"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "original_mod_type"
    t.index ["entity_id"], name: "index_entitybuilder_modifiers_on_entity_id"
    t.index ["modifierable_id", "modifierable_type"], name: "eb_modifier_id_and_type"
  end

  create_table "entitybuilder_movements", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "entity_id"
    t.integer "sort_order"
    t.text "name", null: false
    t.integer "base"
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "bonus"
    t.text "ability_score"
    t.integer "misc_modifier"
    t.text "dice"
    t.index ["entity_id"], name: "index_entitybuilder_movements_on_entity_id"
  end

  create_table "entitybuilder_notables", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "notableable_id"
    t.text "notableable_type"
    t.text "entity_id"
    t.text "name"
    t.integer "sort_order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entity_id"], name: "index_entitybuilder_notables_on_entity_id"
    t.index ["notableable_id", "notableable_type"], name: "eb_notable_id_and_type"
  end

  create_table "entitybuilder_saving_throws", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "entity_id"
    t.integer "sort_order"
    t.text "name"
    t.text "description"
    t.integer "base"
    t.integer "bonus"
    t.text "ability_score"
    t.integer "misc_modifier"
    t.text "dice"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "proficient"
    t.index ["entity_id"], name: "index_entitybuilder_saving_throws_on_entity_id"
  end

  create_table "entitybuilder_skills", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "entity_id"
    t.integer "sort_order"
    t.text "name", null: false
    t.text "description"
    t.integer "bonus"
    t.boolean "class_skill"
    t.text "ability_score"
    t.integer "ranks"
    t.integer "misc_modifier"
    t.text "dice"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "proficient"
    t.string "skill_group", limit: 64
    t.index ["entity_id", "skill_group"], name: "index_entitybuilder_skills_on_entity_id_and_skill_group"
    t.index ["entity_id"], name: "index_entitybuilder_skills_on_entity_id"
  end

  create_table "entitybuilder_trackables", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "entity_id"
    t.integer "sort_order"
    t.text "name", null: false
    t.text "description"
    t.integer "minimum"
    t.integer "maximum"
    t.integer "current"
    t.integer "temporary"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["entity_id"], name: "index_entitybuilder_trackables_on_entity_id"
  end

  create_table "entitybuilder_traits", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "entity_id"
    t.integer "sort_order"
    t.text "name", null: false
    t.text "short_description"
    t.text "full_description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "detail"
    t.index ["entity_id"], name: "index_entitybuilder_traits_on_entity_id"
  end

  create_table "gallery_image_joins", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "image_id", null: false
    t.text "imageable_id", null: false
    t.text "imageable_type", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["imageable_id", "imageable_type"], name: "index_gallery_image_joins_on_imageable_id_and_imageable_type"
  end

  create_table "gallery_images", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "type", null: false
    t.text "resident_id"
    t.text "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "file_file_name"
    t.text "file_content_type"
    t.integer "file_file_size"
    t.datetime "file_updated_at"
    t.boolean "file_processing"
    t.index ["resident_id"], name: "index_gallery_images_on_resident_id"
  end

  create_table "importer_import_files", id: :string, force: :cascade do |t|
    t.string "import_id", null: false
    t.string "kind", null: false
    t.string "parse_status", default: "pending", null: false
    t.json "parse_errors"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "file_file_name"
    t.string "file_content_type"
    t.bigint "file_file_size"
    t.datetime "file_updated_at"
    t.index ["import_id"], name: "index_importer_import_files_on_import_id"
    t.index ["kind"], name: "index_importer_import_files_on_kind"
    t.index ["parse_status"], name: "index_importer_import_files_on_parse_status"
  end

  create_table "importer_import_results", id: :string, force: :cascade do |t|
    t.string "import_file_id", null: false
    t.string "entity_type", null: false
    t.string "entity_name", null: false
    t.string "outcome", null: false
    t.text "reason"
    t.string "record_type"
    t.string "record_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["import_file_id"], name: "index_importer_import_results_on_import_file_id"
    t.index ["outcome"], name: "index_importer_import_results_on_outcome"
    t.index ["record_type", "record_id"], name: "index_importer_import_results_on_record_type_and_record_id"
  end

  create_table "importer_imports", id: :string, force: :cascade do |t|
    t.string "resident_id"
    t.string "preview_id"
    t.string "mode", null: false
    t.string "source", null: false
    t.string "status", null: false
    t.datetime "started_at"
    t.datetime "finished_at"
    t.json "progress"
    t.json "summary"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["mode"], name: "index_importer_imports_on_mode"
    t.index ["preview_id"], name: "index_importer_imports_on_preview_id"
    t.index ["resident_id"], name: "index_importer_imports_on_resident_id"
    t.index ["status"], name: "index_importer_imports_on_status"
  end

  create_table "importer_preview_files", id: :string, force: :cascade do |t|
    t.string "preview_id", null: false
    t.string "detected_kind", null: false
    t.string "override_kind"
    t.json "entity_counts"
    t.json "parse_errors"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "file_file_name"
    t.string "file_content_type"
    t.bigint "file_file_size"
    t.datetime "file_updated_at"
    t.index ["detected_kind"], name: "index_importer_preview_files_on_detected_kind"
    t.index ["preview_id"], name: "index_importer_preview_files_on_preview_id"
  end

  create_table "importer_previews", id: :string, force: :cascade do |t|
    t.string "resident_id"
    t.string "mode", null: false
    t.string "source", null: false
    t.string "status", null: false
    t.json "summary"
    t.json "validation_errors"
    t.datetime "expires_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["mode"], name: "index_importer_previews_on_mode"
    t.index ["resident_id"], name: "index_importer_previews_on_resident_id"
    t.index ["status"], name: "index_importer_previews_on_status"
  end

  create_table "messages", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "sender_id", null: false
    t.text "recipient_id"
    t.boolean "sender_deleted", default: false
    t.boolean "recipient_deleted", default: false
    t.text "subject", null: false
    t.text "body"
    t.datetime "read_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["recipient_id"], name: "index_messages_on_recipient_id"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "residents", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "user_id", null: false
    t.text "name", null: false
    t.text "slug", null: false
    t.text "short_description"
    t.text "full_description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "title"
    t.text "badges"
    t.index ["slug"], name: "index_residents_on_slug", unique: true
    t.index ["user_id"], name: "index_residents_on_user_id", unique: true
  end

  create_table "rulebuilder_abilities", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "type", null: false
    t.text "resident_id"
    t.text "core_rules"
    t.text "name"
    t.text "short_description"
    t.text "full_description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "parent_id"
    t.text "publisher"
    t.text "source"
    t.boolean "is_3pp", default: false
    t.text "tags", default: "[]"
    t.index ["parent_id"], name: "index_rulebuilder_abilities_on_parent_id"
    t.index ["resident_id"], name: "index_rulebuilder_abilities_on_resident_id"
    t.index ["tags"], name: "index_rulebuilder_abilities_on_tags"
    t.index ["type"], name: "index_rulebuilder_abilities_on_type"
  end

  create_table "rulebuilder_feats", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "type", null: false
    t.text "resident_id"
    t.text "core_rules"
    t.text "name"
    t.text "short_description"
    t.text "full_description"
    t.text "prerequisites"
    t.text "benefit"
    t.text "normal"
    t.text "special"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "categories", default: "[]"
    t.text "parent_id"
    t.text "publisher"
    t.text "source"
    t.boolean "is_3pp", default: false
    t.text "tags", default: "[]"
    t.index ["categories"], name: "index_rulebuilder_feats_on_categories"
    t.index ["parent_id"], name: "index_rulebuilder_feats_on_parent_id"
    t.index ["resident_id"], name: "index_rulebuilder_feats_on_resident_id"
    t.index ["tags"], name: "index_rulebuilder_feats_on_tags"
    t.index ["type"], name: "index_rulebuilder_feats_on_type"
  end

  create_table "rulebuilder_items", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "type", null: false
    t.text "resident_id"
    t.text "core_rules"
    t.text "name"
    t.text "short_description"
    t.text "full_description"
    t.text "category"
    t.float "weight"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "parent_id"
    t.text "publisher"
    t.text "source"
    t.boolean "is_3pp", default: false
    t.text "tags", default: "[]"
    t.text "privacy", default: "Private", null: false
    t.index ["parent_id"], name: "index_rulebuilder_items_on_parent_id"
    t.index ["privacy"], name: "index_rulebuilder_items_on_privacy"
    t.index ["resident_id"], name: "index_rulebuilder_items_on_resident_id"
    t.index ["tags"], name: "index_rulebuilder_items_on_tags"
    t.index ["type"], name: "index_rulebuilder_items_on_type"
  end

  create_table "rulebuilder_rules", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "type", null: false
    t.text "resident_id"
    t.text "parent_id"
    t.text "core_rules"
    t.text "rule_type"
    t.boolean "is_shared"
    t.text "name"
    t.text "short_description"
    t.text "full_description"
    t.text "publisher"
    t.text "source"
    t.boolean "is_3pp"
    t.text "tags", default: "[]"
    t.text "categories", default: "[]"
    t.text "prerequisites"
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

  create_table "rulebuilder_spells", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "type", null: false
    t.text "resident_id"
    t.text "core_rules"
    t.text "name"
    t.text "short_description"
    t.text "full_description"
    t.text "school"
    t.text "casting_time"
    t.text "components"
    t.text "range"
    t.text "effect"
    t.text "target"
    t.text "area"
    t.text "duration"
    t.text "saving_throw"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "spell_resistance"
    t.text "levels", default: "[]"
    t.text "parent_id"
    t.text "publisher"
    t.text "source"
    t.boolean "is_3pp", default: false
    t.text "tags", default: "[]"
    t.index ["levels"], name: "index_rulebuilder_spells_on_levels"
    t.index ["parent_id"], name: "index_rulebuilder_spells_on_parent_id"
    t.index ["resident_id"], name: "index_rulebuilder_spells_on_resident_id"
    t.index ["tags"], name: "index_rulebuilder_spells_on_tags"
    t.index ["type"], name: "index_rulebuilder_spells_on_type"
  end

  create_table "storybuilder_adventures", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "resident_id"
    t.text "parent_id"
    t.text "name", null: false
    t.text "slug", null: false
    t.text "page_label"
    t.text "privacy", null: false
    t.text "short_description"
    t.text "full_description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "type"
    t.text "core_rules"
    t.index ["parent_id"], name: "index_storybuilder_adventures_on_parent_id"
    t.index ["resident_id"], name: "index_storybuilder_adventures_on_resident_id"
  end

  create_table "storybuilder_features", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "featureable_id"
    t.text "featureable_type"
    t.integer "sort_order"
    t.text "feature_label"
    t.text "feature_text"
    t.text "feature_type"
    t.text "record_type"
    t.text "search_tags"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["featureable_id", "featureable_type"], name: "index_storybuilder_features_id_and_type"
  end

  create_table "storybuilder_menu_item_joins", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "menu_item_id", null: false
    t.text "menu_item_joinable_id", null: false
    t.text "menu_item_joinable_type", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["menu_item_id"], name: "index_storybuilder_menu_item_joins_on_menu_item_id"
    t.index ["menu_item_joinable_id", "menu_item_joinable_type"], name: "sb_menu_item_join_id_and_type"
  end

  create_table "storybuilder_menu_items", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "menu_itemable_id"
    t.text "menu_itemable_type"
    t.integer "sort_order"
    t.text "item_label"
    t.text "item_link"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["menu_itemable_id", "menu_itemable_type"], name: "sb_menu_item_id_and_type"
  end

  create_table "storybuilder_notables", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "notableable_id"
    t.text "notableable_type"
    t.text "entity_id"
    t.text "name"
    t.integer "sort_order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["entity_id"], name: "index_storybuilder_notables_on_entity_id"
    t.index ["notableable_id", "notableable_type"], name: "sb_notable_id_and_type"
  end

  create_table "storybuilder_pages", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "type"
    t.text "parent_id"
    t.text "name"
    t.text "slug"
    t.text "page_label"
    t.text "privacy"
    t.text "short_description"
    t.text "full_description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "adventure_id"
    t.text "tags", default: "[]"
    t.integer "sort_weight", default: 1000, null: false
    t.boolean "player_handout", default: false
    t.index ["adventure_id"], name: "index_storybuilder_pages_on_adventure_id"
    t.index ["parent_id"], name: "index_storybuilder_pages_on_parent_id"
    t.index ["tags"], name: "index_storybuilder_pages_on_tags"
  end

  create_table "storybuilder_sections", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "sectionable_id"
    t.text "sectionable_type"
    t.integer "sort_order"
    t.text "header"
    t.text "content"
    t.text "section_type"
    t.text "section_style"
    t.text "record_type"
    t.text "search_tags"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["sectionable_id", "sectionable_type"], name: "index_storybuilder_sections_id_and_type"
  end

  create_table "support_core_faqs", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "faq_id", null: false
    t.text "core_item", null: false
    t.boolean "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "support_faqs", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "topic"
    t.text "question", null: false
    t.text "answer"
    t.boolean "active", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "email", default: "", null: false
    t.text "encrypted_password", default: "", null: false
    t.text "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.text "current_sign_in_ip"
    t.text "last_sign_in_ip"
    t.text "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.text "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.text "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "status", default: "trial", null: false
    t.text "stripe_customer_token"
    t.string "locale", default: "en", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["status"], name: "index_users_on_status"
    t.index ["stripe_customer_token"], name: "index_users_on_stripe_customer_token"
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "worldbuilder_contributors", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "district_id", null: false
    t.text "affiliation_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["district_id", "affiliation_id"], name: "index_worldbuilder_contributers_district_and_affiliate", unique: true
  end

  create_table "worldbuilder_districts", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "resident_id"
    t.text "name", null: false
    t.text "slug", null: false
    t.text "short_description"
    t.text "full_description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "privacy"
    t.text "page_label"
    t.index ["resident_id"], name: "index_worldbuilder_districts_on_resident_id"
    t.index ["slug"], name: "index_worldbuilder_districts_on_slug", unique: true
  end

  create_table "worldbuilder_features", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "featureable_id"
    t.text "featureable_type"
    t.integer "sort_order"
    t.text "feature_label"
    t.text "feature_text"
    t.text "feature_type"
    t.text "record_type"
    t.text "search_tags"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["featureable_id", "featureable_type"], name: "index_worldbuilder_features_id_and_type"
  end

  create_table "worldbuilder_menu_item_joins", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "menu_item_id", null: false
    t.text "menu_item_joinable_id", null: false
    t.text "menu_item_joinable_type", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["menu_item_id"], name: "index_worldbuilder_menu_item_joins_on_menu_item_id"
    t.index ["menu_item_joinable_id", "menu_item_joinable_type"], name: "wb_menu_item_joins_id_and_type"
  end

  create_table "worldbuilder_menu_items", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "menu_itemable_id"
    t.text "menu_itemable_type"
    t.integer "sort_order"
    t.text "item_label"
    t.text "item_link"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "worldbuilder_pages", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "type"
    t.text "district_id"
    t.text "parent_id"
    t.text "name"
    t.text "slug"
    t.text "page_label"
    t.text "short_description"
    t.text "full_description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "tags", default: "[]"
    t.integer "sort_weight", default: 1000, null: false
    t.index ["district_id", "slug"], name: "index_worldbuilder_pages_on_district_id_and_slug"
    t.index ["parent_id"], name: "index_worldbuilder_pages_on_parent_id"
    t.index ["tags"], name: "index_worldbuilder_pages_on_tags"
  end

  create_table "worldbuilder_sections", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "sectionable_id"
    t.text "sectionable_type"
    t.integer "sort_order"
    t.text "header"
    t.text "content"
    t.text "section_type"
    t.text "section_style"
    t.text "record_type"
    t.text "search_tags"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["sectionable_id", "sectionable_type"], name: "index_worldbuilder_sections_id_and_type"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
