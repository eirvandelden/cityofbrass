class RemovePlanId < ActiveRecord::Migration[5.0]
  def change
    remove_index :billing_subscriptions, :plan_id
    change_column :billing_subscriptions, :plan_id, :uuid, null: true
  end
end
