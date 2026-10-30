class CreateSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :sessions, id: :text, default: -> { "uuid()" } do |t|
      t.text :authenticatable_type, null: false
      t.text :authenticatable_id, null: false
      t.text :ip_address
      t.text :user_agent
      t.timestamps
    end

    add_index :sessions, [ :authenticatable_type, :authenticatable_id ]
  end
end
