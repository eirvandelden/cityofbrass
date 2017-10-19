class CreateWorldbuilderDistricts < ActiveRecord::Migration
  def change
    create_table :worldbuilder_districts, id: :uuid do |t|
      t.uuid   :resident_id
      t.string :name, :null => false
      t.string :slug, :null => false
      t.string :short_description
      t.text   :full_description

      t.timestamps
    end
    
    add_index :worldbuilder_districts, :slug, :unique => true    
  end
end
