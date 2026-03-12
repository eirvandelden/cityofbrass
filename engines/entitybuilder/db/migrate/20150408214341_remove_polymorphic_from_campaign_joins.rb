class RemovePolymorphicFromCampaignJoins < ActiveRecord::Migration[4.2]
  def change
    remove_index :entitybuilder_campaign_joins, name: 'eb_campaign_join_id_and_type'

    rename_column :entitybuilder_campaign_joins, :campaign_joinable_id, :entity_id

    add_index :entitybuilder_campaign_joins, :entity_id
  end
end
