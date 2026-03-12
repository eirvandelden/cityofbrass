class StorybuilderTableChanges < ActiveRecord::Migration[4.2]
  def change
    drop_table :storybuilder_campaigns
    drop_table :storybuilder_players
    drop_table :storybuilder_logs
  end
end
