class AddVersionsToEntitybuilderEntities < ActiveRecord::Migration[8.1]
  def change
    add_column :entitybuilder_entities, :parent_id, :text
    add_column :entitybuilder_entities, :version_label, :string, limit: 64
    add_index :entitybuilder_entities, :parent_id
  end
end
