class RenameDistrictToSetting < ActiveRecord::Migration
  def change
  	remove_index :worldbuilder_districts, :slug
    rename_table :worldbuilder_districts, :worldbuilder_settings
    add_index :worldbuilder_settings, :slug, :unique => true

    remove_index :worldbuilder_atlas_entries, [:district_id, :slug]
    remove_index :worldbuilder_religions, [:district_id, :slug]
    remove_index :worldbuilder_deities, [:district_id, :slug]
    remove_index :worldbuilder_planes, [:district_id, :slug]
    remove_index :worldbuilder_inhabitants, [:district_id, :slug]

    rename_column :worldbuilder_atlas_entries, :district_id, :setting_id
    rename_column :worldbuilder_religions, :district_id, :setting_id
    rename_column :worldbuilder_deities, :district_id, :setting_id
    rename_column :worldbuilder_planes, :district_id, :setting_id
    rename_column :worldbuilder_inhabitants, :district_id, :setting_id

    add_index :worldbuilder_atlas_entries, [:setting_id, :slug], :unique => true
    add_index :worldbuilder_religions, [:setting_id, :slug], :unique => true
    add_index :worldbuilder_deities, [:setting_id, :slug], :unique => true
    add_index :worldbuilder_planes, [:setting_id, :slug], :unique => true
    add_index :worldbuilder_inhabitants, [:setting_id, :slug], :unique => true
  end
end
