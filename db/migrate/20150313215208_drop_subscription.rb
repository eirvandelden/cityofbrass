class DropSubscription < ActiveRecord::Migration[4.2]
  def change
    drop_table :subscriptions, if_exists: true
  end
end
