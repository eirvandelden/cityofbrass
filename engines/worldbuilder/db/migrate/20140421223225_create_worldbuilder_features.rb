class CreateWorldbuilderFeatures < ActiveRecord::Migration
  def change
    create_table :worldbuilder_features, id: :uuid do |t|
      t.uuid :featureable_id
      t.string :featureable_type
      t.integer :sort_order
      t.string :feature_label
      t.text :feature_text
      t.string :feature_type
      t.string :feature_style
      t.string :record_type
      t.string :search_tags

      t.timestamps
    end

    add_index :worldbuilder_features, [:featureable_id, :featureable_type], :name => 'index_worldbuilder_features_id_and_type'
  end
end
