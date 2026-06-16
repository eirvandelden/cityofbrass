class CreateMessages < ActiveRecord::Migration[4.2]
  def change
    create_table :messages, id: :string do |t|
      t.string :sender_id, :null => false
      t.string :recipient_id
      t.boolean :sender_deleted, :recipient_deleted, :default => false
      t.string :subject, :null => false
      t.text :body
      t.datetime :read_at

      t.timestamps
    end

    add_index :messages, :sender_id
    add_index :messages, :recipient_id
  end
end
