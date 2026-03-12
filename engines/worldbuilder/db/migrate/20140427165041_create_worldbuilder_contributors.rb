class CreateWorldbuilderContributors < ActiveRecord::Migration[4.2]
  def change
    create_table :worldbuilder_contributors, id: :string do |t|
      t.string :district_id,  null: false
      t.string :affiliation_id, null: false

      t.timestamps
    end
  end
end
