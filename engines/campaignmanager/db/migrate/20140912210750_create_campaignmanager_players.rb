class CreateCampaignmanagerPlayers < ActiveRecord::Migration[4.2]
  def change
    create_table :campaignmanager_players, id: :string do |t|
      t.string :campaign_id
      t.string :affiliation_id

      t.timestamps
    end

    add_index :campaignmanager_players, [ :campaign_id, :affiliation_id ], unique: true, name: 'index_campaignmanager_players_campaign_and_affiliate'
  end
end
