class CreateCampaignmanagerCampaignAdventureJoins < ActiveRecord::Migration[6.1]
  def change
    create_table :campaignmanager_campaign_adventure_joins, id: :string do |t|
      t.string :campaign_id, null: false
      t.string :adventure_id, null: false
      t.boolean :active, default: false, null: false
      t.timestamps
    end
    add_index :campaignmanager_campaign_adventure_joins, [ :campaign_id, :adventure_id ], unique: true, name: "idx_cm_campaign_adventure_joins_unique"
    add_index :campaignmanager_campaign_adventure_joins, [ :campaign_id, :active ], name: "idx_cm_campaign_adventure_joins_active"
  end
end
