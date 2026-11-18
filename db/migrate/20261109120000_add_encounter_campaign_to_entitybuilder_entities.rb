class AddEncounterCampaignToEntitybuilderEntities < ActiveRecord::Migration[8.1]
  def change
    add_column :entitybuilder_entities, :encounter_campaign_id, :text
    add_index :entitybuilder_entities, :encounter_campaign_id
  end
end
