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

ActiveRecord::Schema.define(version: 2016_11_11_120001) do
  create_table "billing_events", id: :string, force: :cascade do |t|
    t.string "user_id", null: false
    t.text "stripe_event_token", null: false
    t.datetime "event_date"
    t.text "event_type"
    t.json "event_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "stripe_event_token" ], name: "index_billing_events_on_stripe_event_token", unique: true
    t.index [ "user_id" ], name: "index_billing_events_on_user_id"
  end

  create_table "billing_plans", id: :string, force: :cascade do |t|
    t.string "name", null: false
    t.string "stripe_plan_token"
    t.string "interval"
    t.integer "interval_count"
    t.string "currency"
    t.integer "amount"
    t.string "description"
    t.boolean "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "billing_subscriptions", id: :string, force: :cascade do |t|
    t.string "user_id", null: false
    t.string "plan_id"
    t.string "stripe_subscription_token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index [ "stripe_subscription_token" ], name: "index_billing_subscriptions_on_stripe_subscription_token", unique: true
    t.index [ "user_id" ], name: "index_billing_subscriptions_on_user_id", unique: true
  end
end
