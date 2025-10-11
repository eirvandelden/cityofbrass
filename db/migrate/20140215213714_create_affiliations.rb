# frozen_string_literal: false

class CreateAffiliations < ActiveRecord::Migration
  def change
    create_table :affiliations, id: :uuid do |t|
      t.string :resident_id,  :null => false
      t.string :affiliate_id, :null => false
      t.string :status,     :null => false

      t.timestamps
    end

    add_index :affiliations, :resident_id
  end
end
