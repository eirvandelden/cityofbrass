class CreateStorybuilderLogs < ActiveRecord::Migration[4.2]
  def change
    create_table :storybuilder_logs, id: :string do |t|
      t.string :logable_id
      t.string :logable_type
      t.integer :sort_order
      t.string :story_id

      t.timestamps
    end

    add_index :storybuilder_logs, [ :logable_id, :logable_type ], name: 'sb_log_id_and_type'
  end
end
