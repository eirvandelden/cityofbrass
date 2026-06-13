class BackfillCampaignAdventureJoins < ActiveRecord::Migration[6.1]
  def up
    rows = ActiveRecord::Base.connection.execute(
      "SELECT id, adventure_id FROM campaignmanager_campaigns WHERE adventure_id IS NOT NULL"
    )
    rows.each do |row|
      ActiveRecord::Base.connection.execute(
        ActiveRecord::Base.sanitize_sql_array([
          "INSERT INTO campaignmanager_campaign_adventure_joins (id, campaign_id, adventure_id, active, created_at, updated_at) VALUES (?, ?, ?, ?, datetime('now'), datetime('now'))",
          SecureRandom.uuid,
          row["id"],
          row["adventure_id"],
          1
        ])
      )
    end

    remove_column :campaignmanager_campaigns, :adventure_id
  end

  def down
    add_column :campaignmanager_campaigns, :adventure_id, :string
    # No backfill on down — data is gone
  end
end
