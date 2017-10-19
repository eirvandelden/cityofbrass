class AddStatusToUsers < ActiveRecord::Migration
  def change
    add_column :users, :status, :string, null: false, default: "trial"
    add_index :users, :status
  end
end
