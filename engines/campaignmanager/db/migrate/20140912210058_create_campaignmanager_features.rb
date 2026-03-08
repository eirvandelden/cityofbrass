class CreateCampaignmanagerFeatures < ActiveRecord::Migration[4.2]
  def change
    create_table :campaignmanager_features, id: :string do |t|
      t.string :featureable_id
      t.string :featureable_type
      t.integer :sort_order
      t.string :feature_label
      t.text :feature_text
      t.string :feature_type
      t.string :record_type
      t.string :search_tags

      t.timestamps
    end

    add_index :campaignmanager_features, [ :featureable_id, :featureable_type ], name: 'index_campaignmanager_features_id_and_type'
  end
end
