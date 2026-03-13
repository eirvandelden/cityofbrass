class CreateBillingSubscriptions < ActiveRecord::Migration
  def change
    create_table :billing_subscriptions, id: :uuid do |t|
      t.uuid :user_id, :null => false
      t.uuid :plan_id, :null => false
      t.string :stripe_subscription_token, :null => false
      #t.string :status
      #t.datetime :current_period_start
      #t.datetime :current_period_end
      #t.datetime :canceled_at
      #t.boolean :cancel_at_period_end

      t.timestamps null: false
    end

    add_index :billing_subscriptions, :user_id, :unique => true
    add_index :billing_subscriptions, :plan_id
    add_index :billing_subscriptions, :stripe_subscription_token, :unique => true
  end
end
