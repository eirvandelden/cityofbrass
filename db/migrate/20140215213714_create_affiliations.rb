class CreateAffiliations < ActiveRecord::Migration
  def change
    create_table :affiliations, id: :uuid do |t|
      t.uuid :resident_id,  :null => false
      t.uuid :affiliate_id, :null => false
      t.string :status,     :null => false

      t.timestamps
    end
    
    add_index :affiliations, :resident_id
  end
end
