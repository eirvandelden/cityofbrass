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

ActiveRecord::Schema[8.1].define(version: 2026_07_03_122207) do
  create_table "action_text_rich_texts", id: :integer, default: nil, force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", precision: nil, null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activeplay_notables", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.text "entity_id"
    t.text "name"
    t.integer "sort_order"
    t.datetime "updated_at", precision: nil, null: false
    t.text "virtual_table_id"
    t.index ["entity_id"], name: "index_activeplay_notables_on_entity_id"
    t.index ["virtual_table_id"], name: "index_activeplay_notables_on_virtual_table_id"
  end

  create_table "activeplay_virtual_tables", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.text "campaign_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["campaign_id"], name: "index_activeplay_virtual_tables_on_campaign_id", unique: true
  end

  create_table "admins", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.datetime "current_sign_in_at", precision: nil
    t.text "current_sign_in_ip"
    t.text "email", default: "", null: false
    t.text "encrypted_password", default: "", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "last_sign_in_at", precision: nil
    t.text "last_sign_in_ip"
    t.datetime "locked_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.datetime "reset_password_sent_at", precision: nil
    t.text "reset_password_token"
    t.integer "sign_in_count", default: 0, null: false
    t.text "unlock_token"
    t.datetime "updated_at", precision: nil
    t.index ["email"], name: "index_admins_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_admins_on_unlock_token", unique: true
  end

  create_table "affiliations", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.text "affiliate_id", null: false
    t.datetime "created_at", precision: nil
    t.text "resident_id", null: false
    t.text "status", null: false
    t.datetime "updated_at", precision: nil
    t.index ["affiliate_id", "resident_id"], name: "index_affiliations_on_affiliate_id_and_resident_id"
    t.index ["affiliate_id"], name: "index_affiliations_on_affiliate_id"
    t.index ["resident_id"], name: "index_affiliations_on_resident_id"
  end

  create_table "beta_invites", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.text "email"
    t.datetime "updated_at", precision: nil
    t.index ["email"], name: "index_beta_invites_on_email", unique: true
  end

  create_table "billing_events", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.text "event_data"
    t.datetime "event_date", precision: nil
    t.text "event_type"
    t.text "stripe_event_token", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "user_id", null: false
    t.index ["stripe_event_token"], name: "index_billing_events_on_stripe_event_token", unique: true
    t.index ["user_id"], name: "index_billing_events_on_user_id"
  end

  create_table "billing_plans", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.boolean "active"
    t.integer "amount"
    t.datetime "created_at", precision: nil, null: false
    t.text "currency"
    t.text "description"
    t.text "interval"
    t.integer "interval_count"
    t.text "name", null: false
    t.text "stripe_plan_token"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "billing_subscriptions", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.text "plan_id"
    t.text "stripe_subscription_token", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "user_id", null: false
    t.index ["stripe_subscription_token"], name: "index_billing_subscriptions_on_stripe_subscription_token", unique: true
    t.index ["user_id"], name: "index_billing_subscriptions_on_user_id", unique: true
  end

  create_table "campaignmanager_campaign_adventure_joins", id: :string, force: :cascade do |t|
    t.boolean "active", default: false, null: false
    t.string "adventure_id", null: false
    t.string "campaign_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id", "active"], name: "idx_cm_campaign_adventure_joins_active"
    t.index ["campaign_id", "adventure_id"], name: "idx_cm_campaign_adventure_joins_unique", unique: true
  end

  create_table "campaignmanager_campaigns", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "core_rules"
    t.datetime "created_at", precision: nil
    t.text "district_id"
    t.text "full_description"
    t.text "name", null: false
    t.text "page_label"
    t.text "privacy", null: false
    t.text "resident_id", null: false
    t.text "short_description"
    t.text "slug", null: false
    t.datetime "updated_at", precision: nil
    t.index ["district_id"], name: "index_campaignmanager_campaigns_on_district_id"
    t.index ["resident_id"], name: "index_campaignmanager_campaigns_on_resident_id"
  end

  create_table "campaignmanager_features", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.text "feature_label"
    t.text "feature_text"
    t.text "feature_type"
    t.text "featureable_id"
    t.text "featureable_type"
    t.text "record_type"
    t.text "search_tags"
    t.integer "sort_order"
    t.datetime "updated_at", precision: nil
    t.index ["featureable_id", "featureable_type"], name: "index_campaignmanager_features_id_and_type"
  end

  create_table "campaignmanager_notables", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.text "entity_id"
    t.text "name"
    t.text "notableable_id"
    t.text "notableable_type"
    t.integer "sort_order"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["entity_id"], name: "index_campaignmanager_notables_on_entity_id"
    t.index ["notableable_id", "notableable_type"], name: "cm_notable_id_and_type"
  end

  create_table "campaignmanager_pages", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "campaign_id"
    t.datetime "created_at", precision: nil
    t.text "full_description", limit: 16777215
    t.text "name"
    t.date "page_date"
    t.text "page_label"
    t.text "parent_id"
    t.text "privacy"
    t.text "short_description"
    t.text "slug"
    t.text "type", null: false
    t.datetime "updated_at", precision: nil
    t.index ["campaign_id"], name: "index_campaignmanager_pages_on_campaign_id"
    t.index ["parent_id"], name: "index_campaignmanager_pages_on_parent_id"
  end

  create_table "campaignmanager_players", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.text "affiliation_id"
    t.text "campaign_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["campaign_id", "affiliation_id"], name: "index_campaignmanager_players_campaign_and_affiliate", unique: true
  end

  create_table "campaignmanager_sections", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", precision: nil
    t.text "header"
    t.text "record_type"
    t.text "search_tags"
    t.text "section_style"
    t.text "section_type"
    t.text "sectionable_id"
    t.text "sectionable_type"
    t.integer "sort_order"
    t.datetime "updated_at", precision: nil
    t.index ["sectionable_id", "sectionable_type"], name: "index_campaignmanager_sections_id_and_type"
  end

  create_table "entitybuilder_ability_scores", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.integer "base"
    t.datetime "created_at", precision: nil
    t.text "description"
    t.text "dice"
    t.text "entity_id"
    t.integer "modifier"
    t.text "name", null: false
    t.integer "score"
    t.integer "sort_order"
    t.datetime "updated_at", precision: nil
    t.index ["entity_id"], name: "index_entitybuilder_ability_scores_on_entity_id"
  end

  create_table "entitybuilder_attacks", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.text "attack_ability_score"
    t.integer "attack_bonus"
    t.text "attack_dice"
    t.integer "attack_misc_modifier"
    t.text "attack_range"
    t.text "attack_type"
    t.datetime "created_at", precision: nil
    t.text "critical_damage_ability_score"
    t.integer "critical_damage_bonus"
    t.text "critical_damage_dice"
    t.integer "critical_damage_misc_modifier"
    t.text "critical_range"
    t.text "damage_ability_score"
    t.integer "damage_bonus"
    t.text "damage_dice"
    t.integer "damage_misc_modifier"
    t.text "damage_type"
    t.text "description"
    t.text "entity_id"
    t.text "name", null: false
    t.boolean "proficient"
    t.integer "sort_order"
    t.text "special_damage_ability_score"
    t.integer "special_damage_bonus"
    t.text "special_damage_dice"
    t.integer "special_damage_misc_modifier"
    t.text "special_damage_name"
    t.datetime "updated_at", precision: nil
    t.index ["entity_id"], name: "index_entitybuilder_attacks_on_entity_id"
  end

  create_table "entitybuilder_base_values", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.text "description"
    t.text "dice"
    t.text "entity_id"
    t.text "name", null: false
    t.integer "sort_order"
    t.datetime "updated_at", precision: nil
    t.integer "value"
    t.index ["entity_id"], name: "index_entitybuilder_base_values_on_entity_id"
  end

  create_table "entitybuilder_campaign_joins", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.text "campaign_id"
    t.datetime "created_at", precision: nil
    t.text "entity_id"
    t.datetime "updated_at", precision: nil
    t.index ["entity_id"], name: "index_entitybuilder_campaign_joins_on_entity_id"
  end

  create_table "entitybuilder_caster_levels", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.text "ability_score"
    t.integer "base_dc"
    t.integer "bonus_per_day"
    t.text "caster_class"
    t.datetime "created_at", precision: nil
    t.text "entity_id"
    t.integer "level"
    t.integer "per_day"
    t.boolean "proficient"
    t.integer "save_dc"
    t.integer "sort_order"
    t.datetime "updated_at", precision: nil
    t.index ["entity_id"], name: "index_entitybuilder_caster_levels_on_entity_id"
  end

  create_table "entitybuilder_class_levels", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.text "description"
    t.text "entity_id"
    t.text "hit_dice"
    t.integer "hit_points"
    t.integer "level"
    t.text "name", null: false
    t.integer "sort_order"
    t.datetime "updated_at", precision: nil
    t.index ["entity_id"], name: "index_entitybuilder_class_levels_on_entity_id"
  end

  create_table "entitybuilder_currencies", id: :text, default: "uuid()", force: :cascade do |t|
    t.boolean "carried"
    t.datetime "created_at", precision: nil
    t.text "description"
    t.text "entity_id"
    t.text "name"
    t.integer "quantity"
    t.integer "sort_order"
    t.datetime "updated_at", precision: nil
    t.float "weight"
    t.index ["entity_id"], name: "index_entitybuilder_currencies_on_entity_id"
  end

  create_table "entitybuilder_defenses", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.text "ability_score"
    t.integer "base"
    t.integer "bonus"
    t.datetime "created_at", precision: nil
    t.text "description"
    t.text "dice"
    t.text "entity_id"
    t.integer "misc_modifier"
    t.text "name", null: false
    t.integer "sort_order"
    t.datetime "updated_at", precision: nil
    t.index ["entity_id"], name: "index_entitybuilder_defenses_on_entity_id"
  end

  create_table "entitybuilder_descriptors", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.text "description"
    t.text "entity_id"
    t.boolean "is_private", default: false
    t.text "name", null: false
    t.integer "sort_order"
    t.datetime "updated_at", precision: nil
    t.index ["entity_id"], name: "index_entitybuilder_descriptors_on_entity_id"
  end

  create_table "entitybuilder_entities", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.text "core_rules"
    t.datetime "created_at", precision: nil, null: false
    t.text "full_description"
    t.text "introduction"
    t.boolean "is_3pp", default: false
    t.text "name"
    t.text "notes"
    t.text "privacy"
    t.text "publisher"
    t.text "resident_id"
    t.text "sheet_privacy"
    t.text "short_description"
    t.text "source"
    t.text "tags", default: "[]"
    t.text "type", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["resident_id"], name: "index_entitybuilder_entities_on_resident_id"
    t.index ["tags"], name: "index_entitybuilder_entities_on_tags"
    t.index ["type"], name: "index_entitybuilder_entities_on_type"
  end

  create_table "entitybuilder_inventory_items", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.boolean "carried"
    t.datetime "created_at", precision: nil
    t.text "detail"
    t.text "entity_id"
    t.boolean "equipped"
    t.text "item_id"
    t.integer "quantity"
    t.integer "sort_order"
    t.datetime "updated_at", precision: nil
    t.index ["entity_id"], name: "index_entitybuilder_inventory_items_on_entity_id"
    t.index ["item_id"], name: "index_entitybuilder_inventory_items_on_item_id"
  end

  create_table "entitybuilder_known_abilities", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.text "ability_id"
    t.datetime "created_at", precision: nil, null: false
    t.text "detail"
    t.text "entity_id"
    t.integer "sort_order"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["ability_id"], name: "index_entitybuilder_known_abilities_on_ability_id"
    t.index ["entity_id"], name: "index_entitybuilder_known_abilities_on_entity_id"
  end

  create_table "entitybuilder_known_feats", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.text "detail"
    t.text "entity_id"
    t.text "feat_id"
    t.integer "sort_order"
    t.datetime "updated_at", precision: nil
    t.index ["entity_id"], name: "index_entitybuilder_known_feats_on_entity_id"
    t.index ["feat_id"], name: "index_entitybuilder_known_feats_on_feat_id"
  end

  create_table "entitybuilder_known_spells", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.boolean "at_will", default: false
    t.datetime "created_at", precision: nil
    t.text "detail"
    t.text "entity_id"
    t.integer "level"
    t.boolean "prepared"
    t.integer "sort_order"
    t.text "spell_class"
    t.text "spell_id"
    t.datetime "updated_at", precision: nil
    t.boolean "used"
    t.index ["entity_id"], name: "index_entitybuilder_known_spells_on_entity_id"
    t.index ["spell_id"], name: "index_entitybuilder_known_spells_on_spell_id"
  end

  create_table "entitybuilder_linked_rules", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.text "detail"
    t.text "entity_id"
    t.text "rule_id"
    t.integer "sort_order"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["entity_id"], name: "index_entitybuilder_linked_rules_on_entity_id"
    t.index ["rule_id"], name: "index_entitybuilder_linked_rules_on_rule_id"
  end

  create_table "entitybuilder_modifiers", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.text "category"
    t.datetime "created_at", precision: nil
    t.text "dice"
    t.text "entity_id"
    t.text "item"
    t.text "modifierable_id"
    t.text "modifierable_type"
    t.text "original_mod_type"
    t.integer "sort_order"
    t.datetime "updated_at", precision: nil
    t.integer "value"
    t.index ["entity_id"], name: "index_entitybuilder_modifiers_on_entity_id"
    t.index ["modifierable_id", "modifierable_type"], name: "eb_modifier_id_and_type"
  end

  create_table "entitybuilder_movements", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.text "ability_score"
    t.integer "base"
    t.integer "bonus"
    t.datetime "created_at", precision: nil
    t.text "description"
    t.text "dice"
    t.text "entity_id"
    t.integer "misc_modifier"
    t.text "name", null: false
    t.integer "sort_order"
    t.datetime "updated_at", precision: nil
    t.index ["entity_id"], name: "index_entitybuilder_movements_on_entity_id"
  end

  create_table "entitybuilder_notables", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.text "entity_id"
    t.text "name"
    t.text "notableable_id"
    t.text "notableable_type"
    t.integer "sort_order"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["entity_id"], name: "index_entitybuilder_notables_on_entity_id"
    t.index ["notableable_id", "notableable_type"], name: "eb_notable_id_and_type"
  end

  create_table "entitybuilder_saving_throws", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.text "ability_score"
    t.integer "base"
    t.integer "bonus"
    t.datetime "created_at", precision: nil
    t.text "description"
    t.text "dice"
    t.text "entity_id"
    t.integer "misc_modifier"
    t.text "name"
    t.boolean "proficient"
    t.integer "sort_order"
    t.datetime "updated_at", precision: nil
    t.index ["entity_id"], name: "index_entitybuilder_saving_throws_on_entity_id"
  end

  create_table "entitybuilder_skills", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "ability_score"
    t.integer "bonus"
    t.boolean "class_skill"
    t.datetime "created_at", precision: nil
    t.text "description"
    t.text "dice"
    t.text "entity_id"
    t.integer "misc_modifier"
    t.text "name", null: false
    t.boolean "proficient"
    t.integer "ranks"
    t.string "skill_group", limit: 64
    t.integer "sort_order"
    t.datetime "updated_at", precision: nil
    t.index ["entity_id", "skill_group"], name: "index_entitybuilder_skills_on_entity_id_and_skill_group"
    t.index ["entity_id"], name: "index_entitybuilder_skills_on_entity_id"
  end

  create_table "entitybuilder_trackables", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.integer "current"
    t.text "description"
    t.text "entity_id"
    t.integer "maximum"
    t.integer "minimum"
    t.text "name", null: false
    t.integer "sort_order"
    t.integer "temporary"
    t.datetime "updated_at", precision: nil
    t.index ["entity_id"], name: "index_entitybuilder_trackables_on_entity_id"
  end

  create_table "entitybuilder_traits", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.text "detail"
    t.text "entity_id"
    t.text "full_description"
    t.text "name", null: false
    t.text "short_description"
    t.integer "sort_order"
    t.datetime "updated_at", precision: nil
    t.index ["entity_id"], name: "index_entitybuilder_traits_on_entity_id"
  end

  create_table "gallery_image_joins", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.text "image_id", null: false
    t.text "imageable_id", null: false
    t.text "imageable_type", null: false
    t.datetime "updated_at", precision: nil
    t.index ["imageable_id", "imageable_type"], name: "index_gallery_image_joins_on_imageable_id_and_imageable_type"
  end

  create_table "gallery_images", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.text "file_content_type"
    t.text "file_file_name"
    t.integer "file_file_size"
    t.boolean "file_processing"
    t.datetime "file_updated_at", precision: nil
    t.text "name"
    t.text "resident_id"
    t.text "type", null: false
    t.datetime "updated_at", precision: nil
    t.index ["resident_id"], name: "index_gallery_images_on_resident_id"
  end

  create_table "importer_import_files", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "file_content_type"
    t.string "file_file_name"
    t.bigint "file_file_size"
    t.datetime "file_updated_at", precision: nil
    t.string "import_id", null: false
    t.string "kind", null: false
    t.json "parse_errors"
    t.string "parse_status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["import_id"], name: "index_importer_import_files_on_import_id"
    t.index ["kind"], name: "index_importer_import_files_on_kind"
    t.index ["parse_status"], name: "index_importer_import_files_on_parse_status"
  end

  create_table "importer_import_results", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "entity_name", null: false
    t.string "entity_type", null: false
    t.string "import_file_id", null: false
    t.string "outcome", null: false
    t.text "reason"
    t.string "record_id"
    t.string "record_type"
    t.datetime "updated_at", null: false
    t.index ["import_file_id"], name: "index_importer_import_results_on_import_file_id"
    t.index ["outcome"], name: "index_importer_import_results_on_outcome"
    t.index ["record_type", "record_id"], name: "index_importer_import_results_on_record_type_and_record_id"
  end

  create_table "importer_imports", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "finished_at", precision: nil
    t.string "mode", null: false
    t.string "preview_id"
    t.json "progress"
    t.string "resident_id"
    t.string "source", null: false
    t.datetime "started_at", precision: nil
    t.string "status", null: false
    t.json "summary"
    t.datetime "updated_at", null: false
    t.index ["mode"], name: "index_importer_imports_on_mode"
    t.index ["preview_id"], name: "index_importer_imports_on_preview_id"
    t.index ["resident_id"], name: "index_importer_imports_on_resident_id"
    t.index ["status"], name: "index_importer_imports_on_status"
  end

  create_table "importer_preview_files", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "detected_kind", null: false
    t.json "entity_counts"
    t.string "file_content_type"
    t.string "file_file_name"
    t.bigint "file_file_size"
    t.datetime "file_updated_at", precision: nil
    t.string "override_kind"
    t.json "parse_errors"
    t.string "preview_id", null: false
    t.datetime "updated_at", null: false
    t.index ["detected_kind"], name: "index_importer_preview_files_on_detected_kind"
    t.index ["preview_id"], name: "index_importer_preview_files_on_preview_id"
  end

  create_table "importer_previews", id: :string, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", precision: nil
    t.string "mode", null: false
    t.string "resident_id"
    t.string "source", null: false
    t.string "status", null: false
    t.json "summary"
    t.datetime "updated_at", null: false
    t.json "validation_errors"
    t.index ["mode"], name: "index_importer_previews_on_mode"
    t.index ["resident_id"], name: "index_importer_previews_on_resident_id"
    t.index ["status"], name: "index_importer_previews_on_status"
  end

  create_table "messages", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", precision: nil
    t.datetime "read_at", precision: nil
    t.boolean "recipient_deleted", default: false
    t.text "recipient_id"
    t.boolean "sender_deleted", default: false
    t.text "sender_id", null: false
    t.text "subject", null: false
    t.datetime "updated_at", precision: nil
    t.index ["recipient_id"], name: "index_messages_on_recipient_id"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "residents", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.text "badges"
    t.datetime "created_at", precision: nil
    t.text "full_description"
    t.text "name", null: false
    t.text "short_description"
    t.text "slug", null: false
    t.text "title"
    t.datetime "updated_at", precision: nil
    t.text "user_id", null: false
    t.index ["slug"], name: "index_residents_on_slug", unique: true
    t.index ["user_id"], name: "index_residents_on_user_id", unique: true
  end

  create_table "rulebuilder_abilities", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.text "core_rules"
    t.datetime "created_at", precision: nil, null: false
    t.text "full_description"
    t.boolean "is_3pp", default: false
    t.text "name"
    t.text "parent_id"
    t.text "publisher"
    t.text "resident_id"
    t.text "short_description"
    t.text "source"
    t.text "tags", default: "[]"
    t.text "type", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["parent_id"], name: "index_rulebuilder_abilities_on_parent_id"
    t.index ["resident_id"], name: "index_rulebuilder_abilities_on_resident_id"
    t.index ["tags"], name: "index_rulebuilder_abilities_on_tags"
    t.index ["type"], name: "index_rulebuilder_abilities_on_type"
  end

  create_table "rulebuilder_feats", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.text "benefit"
    t.text "categories", default: "[]"
    t.text "core_rules"
    t.datetime "created_at", precision: nil, null: false
    t.text "full_description"
    t.boolean "is_3pp", default: false
    t.text "name"
    t.text "normal"
    t.text "parent_id"
    t.text "prerequisites"
    t.text "publisher"
    t.text "resident_id"
    t.text "short_description"
    t.text "source"
    t.text "special"
    t.text "tags", default: "[]"
    t.text "type", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["categories"], name: "index_rulebuilder_feats_on_categories"
    t.index ["parent_id"], name: "index_rulebuilder_feats_on_parent_id"
    t.index ["resident_id"], name: "index_rulebuilder_feats_on_resident_id"
    t.index ["tags"], name: "index_rulebuilder_feats_on_tags"
    t.index ["type"], name: "index_rulebuilder_feats_on_type"
  end

  create_table "rulebuilder_items", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "category"
    t.text "core_rules"
    t.datetime "created_at", precision: nil, null: false
    t.text "full_description"
    t.boolean "is_3pp", default: false
    t.text "name"
    t.text "parent_id"
    t.string "privacy", default: "Private", null: false
    t.text "publisher"
    t.text "resident_id"
    t.text "short_description"
    t.text "source"
    t.text "tags", default: "[]"
    t.text "type", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.float "weight"
    t.index ["parent_id"], name: "index_rulebuilder_items_on_parent_id"
    t.index ["privacy"], name: "index_rulebuilder_items_on_privacy"
    t.index ["resident_id"], name: "index_rulebuilder_items_on_resident_id"
    t.index ["tags"], name: "index_rulebuilder_items_on_tags"
    t.index ["type"], name: "index_rulebuilder_items_on_type"
  end

  create_table "rulebuilder_rules", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.text "benefit"
    t.text "categories", default: "[]"
    t.text "core_rules"
    t.datetime "created_at", precision: nil, null: false
    t.text "full_description"
    t.boolean "is_3pp"
    t.boolean "is_shared"
    t.text "name"
    t.text "normal"
    t.text "parent_id"
    t.text "prerequisites"
    t.text "publisher"
    t.text "resident_id"
    t.text "rule_type"
    t.text "short_description"
    t.text "source"
    t.text "special"
    t.text "tags", default: "[]"
    t.text "type", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["categories"], name: "index_rulebuilder_rules_on_categories"
    t.index ["parent_id"], name: "index_rulebuilder_rules_on_parent_id"
    t.index ["resident_id"], name: "index_rulebuilder_rules_on_resident_id"
    t.index ["tags"], name: "index_rulebuilder_rules_on_tags"
    t.index ["type"], name: "index_rulebuilder_rules_on_type"
  end

  create_table "rulebuilder_spells", id: :text, default: "uuid()", force: :cascade do |t|
    t.text "area"
    t.text "casting_time"
    t.text "components"
    t.text "core_rules"
    t.datetime "created_at", precision: nil, null: false
    t.text "duration"
    t.text "effect"
    t.text "full_description"
    t.boolean "is_3pp", default: false
    t.text "levels", default: "[]"
    t.text "name"
    t.text "parent_id"
    t.text "publisher"
    t.text "range"
    t.text "resident_id"
    t.text "saving_throw"
    t.text "school"
    t.text "short_description"
    t.text "source"
    t.text "spell_resistance"
    t.text "tags", default: "[]"
    t.text "target"
    t.text "type", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["levels"], name: "index_rulebuilder_spells_on_levels"
    t.index ["parent_id"], name: "index_rulebuilder_spells_on_parent_id"
    t.index ["resident_id"], name: "index_rulebuilder_spells_on_resident_id"
    t.index ["tags"], name: "index_rulebuilder_spells_on_tags"
    t.index ["type"], name: "index_rulebuilder_spells_on_type"
  end

  create_table "storybuilder_adventures", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.text "core_rules"
    t.datetime "created_at", precision: nil
    t.text "full_description"
    t.text "name", null: false
    t.text "page_label"
    t.text "parent_id"
    t.text "privacy", null: false
    t.text "resident_id"
    t.text "short_description"
    t.text "slug", null: false
    t.text "type"
    t.datetime "updated_at", precision: nil
    t.index ["parent_id"], name: "index_storybuilder_adventures_on_parent_id"
    t.index ["resident_id"], name: "index_storybuilder_adventures_on_resident_id"
  end

  create_table "storybuilder_features", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.text "feature_label"
    t.text "feature_text"
    t.text "feature_type"
    t.text "featureable_id"
    t.text "featureable_type"
    t.text "record_type"
    t.text "search_tags"
    t.integer "sort_order"
    t.datetime "updated_at", precision: nil
    t.index ["featureable_id", "featureable_type"], name: "index_storybuilder_features_id_and_type"
  end

  create_table "storybuilder_menu_item_joins", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.text "menu_item_id", null: false
    t.text "menu_item_joinable_id", null: false
    t.text "menu_item_joinable_type", null: false
    t.datetime "updated_at", precision: nil
    t.index ["menu_item_id"], name: "index_storybuilder_menu_item_joins_on_menu_item_id"
    t.index ["menu_item_joinable_id", "menu_item_joinable_type"], name: "sb_menu_item_join_id_and_type"
  end

  create_table "storybuilder_menu_items", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.text "item_label"
    t.text "item_link"
    t.text "menu_itemable_id"
    t.text "menu_itemable_type"
    t.integer "sort_order"
    t.datetime "updated_at", precision: nil
    t.index ["menu_itemable_id", "menu_itemable_type"], name: "sb_menu_item_id_and_type"
  end

  create_table "storybuilder_notables", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.text "entity_id"
    t.text "name"
    t.text "notableable_id"
    t.text "notableable_type"
    t.integer "sort_order"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["entity_id"], name: "index_storybuilder_notables_on_entity_id"
    t.index ["notableable_id", "notableable_type"], name: "sb_notable_id_and_type"
  end

  create_table "storybuilder_pages", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.text "adventure_id"
    t.datetime "created_at", precision: nil
    t.text "full_description"
    t.text "name"
    t.text "page_label"
    t.text "parent_id"
    t.boolean "player_handout", default: false
    t.text "privacy"
    t.text "short_description"
    t.text "slug"
    t.integer "sort_weight", default: 1000, null: false
    t.text "tags", default: "[]"
    t.text "type"
    t.datetime "updated_at", precision: nil
    t.index ["adventure_id"], name: "index_storybuilder_pages_on_adventure_id"
    t.index ["parent_id"], name: "index_storybuilder_pages_on_parent_id"
    t.index ["tags"], name: "index_storybuilder_pages_on_tags"
  end

  create_table "storybuilder_sections", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", precision: nil
    t.text "header"
    t.text "record_type"
    t.text "search_tags"
    t.text "section_style"
    t.text "section_type"
    t.text "sectionable_id"
    t.text "sectionable_type"
    t.integer "sort_order"
    t.datetime "updated_at", precision: nil
    t.index ["sectionable_id", "sectionable_type"], name: "index_storybuilder_sections_id_and_type"
  end

  create_table "support_core_faqs", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.boolean "active", null: false
    t.text "core_item", null: false
    t.datetime "created_at", precision: nil, null: false
    t.text "faq_id", null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "support_faqs", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.boolean "active", null: false
    t.text "answer"
    t.datetime "created_at", precision: nil
    t.text "question", null: false
    t.text "topic"
    t.datetime "updated_at", precision: nil
  end

  create_table "users", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.datetime "confirmation_sent_at", precision: nil
    t.text "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "current_sign_in_at", precision: nil
    t.text "current_sign_in_ip"
    t.text "email", default: "", null: false
    t.text "encrypted_password", default: "", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "last_sign_in_at", precision: nil
    t.text "last_sign_in_ip"
    t.string "locale", default: "en", null: false
    t.datetime "locked_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.datetime "reset_password_sent_at", precision: nil
    t.text "reset_password_token"
    t.integer "sign_in_count", default: 0, null: false
    t.text "status", default: "trial", null: false
    t.text "stripe_customer_token"
    t.text "unconfirmed_email"
    t.text "unlock_token"
    t.datetime "updated_at", precision: nil
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["status"], name: "index_users_on_status"
    t.index ["stripe_customer_token"], name: "index_users_on_stripe_customer_token"
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "worldbuilder_contributors", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.text "affiliation_id", null: false
    t.datetime "created_at", precision: nil
    t.text "district_id", null: false
    t.datetime "updated_at", precision: nil
    t.index ["district_id", "affiliation_id"], name: "index_worldbuilder_contributers_district_and_affiliate", unique: true
  end

  create_table "worldbuilder_districts", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.text "full_description"
    t.text "name", null: false
    t.text "page_label"
    t.text "privacy"
    t.text "resident_id"
    t.text "short_description"
    t.text "slug", null: false
    t.datetime "updated_at", precision: nil
    t.index ["resident_id"], name: "index_worldbuilder_districts_on_resident_id"
    t.index ["slug"], name: "index_worldbuilder_districts_on_slug", unique: true
  end

  create_table "worldbuilder_features", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.text "feature_label"
    t.text "feature_text"
    t.text "feature_type"
    t.text "featureable_id"
    t.text "featureable_type"
    t.text "record_type"
    t.text "search_tags"
    t.integer "sort_order"
    t.datetime "updated_at", precision: nil
    t.index ["featureable_id", "featureable_type"], name: "index_worldbuilder_features_id_and_type"
  end

  create_table "worldbuilder_menu_item_joins", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.text "menu_item_id", null: false
    t.text "menu_item_joinable_id", null: false
    t.text "menu_item_joinable_type", null: false
    t.datetime "updated_at", precision: nil
    t.index ["menu_item_id"], name: "index_worldbuilder_menu_item_joins_on_menu_item_id"
    t.index ["menu_item_joinable_id", "menu_item_joinable_type"], name: "wb_menu_item_joins_id_and_type"
  end

  create_table "worldbuilder_menu_items", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.text "item_label"
    t.text "item_link"
    t.text "menu_itemable_id"
    t.text "menu_itemable_type"
    t.integer "sort_order"
    t.datetime "updated_at", precision: nil
  end

  create_table "worldbuilder_pages", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.text "district_id"
    t.text "full_description"
    t.text "name"
    t.text "page_label"
    t.text "parent_id"
    t.text "short_description"
    t.text "slug"
    t.integer "sort_weight", default: 1000, null: false
    t.text "tags", default: "[]"
    t.text "type"
    t.datetime "updated_at", precision: nil
    t.index ["district_id", "slug"], name: "index_worldbuilder_pages_on_district_id_and_slug"
    t.index ["parent_id"], name: "index_worldbuilder_pages_on_parent_id"
    t.index ["tags"], name: "index_worldbuilder_pages_on_tags"
  end

  create_table "worldbuilder_sections", id: :text, default: -> { "uuid()" }, force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", precision: nil
    t.text "header"
    t.text "record_type"
    t.text "search_tags"
    t.text "section_style"
    t.text "section_type"
    t.text "sectionable_id"
    t.text "sectionable_type"
    t.integer "sort_order"
    t.datetime "updated_at", precision: nil
    t.index ["sectionable_id", "sectionable_type"], name: "index_worldbuilder_sections_id_and_type"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
