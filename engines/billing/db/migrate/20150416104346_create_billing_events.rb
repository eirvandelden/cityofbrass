# frozen_string_literal: false

class CreateBillingEvents < ActiveRecord::Migration
  def change
    create_table :billing_events, id: :uuid do |t|
      t.uuid :user_id, :null => false
      t.text :stripe_event_token, :null => false
      t.datetime :event_date
      t.text :event_type
      t.json :event_data

      t.timestamps null: false
    end

    add_index :billing_events, :user_id
    add_index :billing_events, :stripe_event_token, :unique => true
  end
end
