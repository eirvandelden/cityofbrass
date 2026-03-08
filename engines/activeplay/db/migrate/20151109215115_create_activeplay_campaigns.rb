class CreateActiveplayCampaigns < ActiveRecord::Migration[4.2]
  def change
    create_table :activeplay_campaigns, id: :string do |t|
      t.string :campaign_id

      t.timestamps null: false
    end

    add_index :activeplay_campaigns, :campaign_id, unique: true
  end
end
