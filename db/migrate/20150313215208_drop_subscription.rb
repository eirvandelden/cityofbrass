# frozen_string_literal: false

class DropSubscription < ActiveRecord::Migration
  def change
    drop_table :subscriptions
  end
end
