class AddResidentIdToFeatsAndItems < ActiveRecord::Migration[4.2]
  def change
    remove_column :entitybuilder_feats, :sort_order, :integer
    remove_column :entitybuilder_items, :sort_order, :integer

    add_column :entitybuilder_feats, :resident_id, :string
    add_column :entitybuilder_feats, :core_rules, :string

    add_column :entitybuilder_items, :resident_id, :string
    add_column :entitybuilder_items, :core_rules, :string

    add_index :entitybuilder_feats, :resident_id
    add_index :entitybuilder_items, :resident_id
  end
end
