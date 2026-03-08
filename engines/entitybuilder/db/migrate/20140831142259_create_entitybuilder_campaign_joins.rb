class CreateEntitybuilderCampaignJoins < ActiveRecord::Migration[4.2]
  def change
    create_table :entitybuilder_campaign_joins, id: :string do |t|
      t.string :campaign_joinable_id
      t.string :campaign_joinable_type
      t.string :campaign_id

      t.timestamps
    end

    add_index :entitybuilder_campaign_joins, [ :campaign_joinable_id, :campaign_joinable_type ], name: 'eb_campaign_join_id_and_type'
  end
end
