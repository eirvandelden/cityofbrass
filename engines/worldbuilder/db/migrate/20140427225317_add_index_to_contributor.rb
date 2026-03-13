class AddIndexToContributor < ActiveRecord::Migration
  def change
    add_index :worldbuilder_contributors, [:district_id, :affiliation_id], :unique => true, :name => 'index_worldbuilder_contributers_district_and_affiliate'
  end
end
