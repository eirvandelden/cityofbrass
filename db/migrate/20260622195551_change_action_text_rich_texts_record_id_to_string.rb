class ChangeActionTextRichTextsRecordIdToString < ActiveRecord::Migration[6.1]
  def up
    remove_index :action_text_rich_texts, name: "index_action_text_rich_texts_uniqueness"
    change_column :action_text_rich_texts, :record_id, :string, null: false
    add_index :action_text_rich_texts, [ :record_type, :record_id, :name ],
              name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  def down
    remove_index :action_text_rich_texts, name: "index_action_text_rich_texts_uniqueness"
    change_column :action_text_rich_texts, :record_id, :bigint, null: false
    add_index :action_text_rich_texts, [ :record_type, :record_id, :name ],
              name: "index_action_text_rich_texts_uniqueness", unique: true
  end
end
