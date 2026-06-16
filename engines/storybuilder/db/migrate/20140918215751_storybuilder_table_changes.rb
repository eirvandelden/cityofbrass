class StorybuilderTableChanges < ActiveRecord::Migration[4.2]
  def change
    drop_table :storybuilder_campaigns, if_exists: true
    drop_table :storybuilder_players, if_exists: true
    drop_table :storybuilder_logs, if_exists: true
  end
end
