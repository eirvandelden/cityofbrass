class CreateEntitybuilderCampaignJoins < ActiveRecord::Migration
  def change
    create_table :entitybuilder_campaign_joins, id: :uuid do |t|
      t.uuid :campaign_joinable_id
      t.string :campaign_joinable_type
      t.uuid :campaign_id

      t.timestamps
    end

    add_index :entitybuilder_campaign_joins, [:campaign_joinable_id, :campaign_joinable_type], :name => 'eb_campaign_join_id_and_type'
  end
end
