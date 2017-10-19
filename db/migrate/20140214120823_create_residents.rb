class CreateResidents < ActiveRecord::Migration
  def change
    create_table :residents, id: :uuid do |t|
      t.uuid   :user_id, :null => false
      t.string :name, 	 :null => false
      t.string :slug, 	 :null => false
      t.string :short_description
      t.text   :full_description

      t.timestamps
    end

    add_index :residents, :user_id, :unique => true
    add_index :residents, :slug, 	:unique => true
  end
end
