# frozen_string_literal: false

class CreateStorybuilderLogs < ActiveRecord::Migration
  def change
    create_table :storybuilder_logs, id: :uuid do |t|
      t.uuid :logable_id
      t.string :logable_type
      t.integer :sort_order
      t.uuid :story_id

      t.timestamps
    end

    add_index :storybuilder_logs, [:logable_id, :logable_type], :name => 'sb_log_id_and_type'
  end
end
