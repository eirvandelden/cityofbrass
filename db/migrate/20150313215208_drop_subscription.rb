class DropSubscription < ActiveRecord::Migration[4.2]
  def change
    drop_table :subscriptions
  end
end
