class CreateAffiliations < ActiveRecord::Migration[4.2]
  def change
    create_table :affiliations, id: :string do |t|
      t.string :resident_id,  :null => false
      t.string :affiliate_id, :null => false
      t.string :status,     :null => false

      t.timestamps
    end

    add_index :affiliations, :resident_id
  end
end
