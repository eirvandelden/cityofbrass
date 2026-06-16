class DropTables < ActiveRecord::Migration[4.2]
  def change
    drop_table :worldbuilder_atlas_entries, if_exists: true
    drop_table :worldbuilder_deities, if_exists: true
    drop_table :worldbuilder_inhabitants, if_exists: true
    drop_table :worldbuilder_lore_records, if_exists: true
    drop_table :worldbuilder_planes, if_exists: true
    drop_table :worldbuilder_religions, if_exists: true
  end
end
