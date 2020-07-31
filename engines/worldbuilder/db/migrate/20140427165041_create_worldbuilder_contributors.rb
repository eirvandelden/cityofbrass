# frozen_string_literal: false

class CreateWorldbuilderContributors < ActiveRecord::Migration
  def change
    create_table :worldbuilder_contributors, id: :uuid do |t|
      t.uuid :district_id,  :null => false
      t.uuid :affiliation_id, :null => false

      t.timestamps
    end
  end
end
