class AddPublisherInfoToEntity < ActiveRecord::Migration
  def change
    add_column :entitybuilder_entities, :publisher, :string
    add_column :entitybuilder_entities, :source, :string
    add_column :entitybuilder_entities, :is_3pp, :boolean, :default => false
    add_column :entitybuilder_entities, :tags, :text, array: true, default: []
    add_index  :entitybuilder_entities, :tags, using: 'gin'
  end
end
