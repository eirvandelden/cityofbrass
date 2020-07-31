# frozen_string_literal: false

class StorybuilderTableChanges < ActiveRecord::Migration
  def change
    drop_table :storybuilder_campaigns
    drop_table :storybuilder_players
    drop_table :storybuilder_logs
  end
end
