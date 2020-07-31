# frozen_string_literal: false

class AddStripeCustomerIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :stripe_customer_token, :string
    add_index :users, :stripe_customer_token
  end
end
