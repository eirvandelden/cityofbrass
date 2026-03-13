class RenameSettingToDistrict < ActiveRecord::Migration
  def change
  	remove_index :worldbuilder_settings, :slug
    rename_table :worldbuilder_settings, :worldbuilder_districts
    add_index :worldbuilder_districts, :slug, :unique => true

    remove_index :worldbuilder_atlas_entries, [:setting_id, :slug]
    remove_index :worldbuilder_religions, [:setting_id, :slug]
    remove_index :worldbuilder_deities, [:setting_id, :slug]
    remove_index :worldbuilder_planes, [:setting_id, :slug]
    remove_index :worldbuilder_inhabitants, [:setting_id, :slug]

    rename_column :worldbuilder_atlas_entries, :setting_id, :district_id
    rename_column :worldbuilder_religions, :setting_id, :district_id
    rename_column :worldbuilder_deities, :setting_id, :district_id
    rename_column :worldbuilder_planes, :setting_id, :district_id
    rename_column :worldbuilder_inhabitants, :setting_id, :district_id

    add_index :worldbuilder_atlas_entries, [:district_id, :slug], :unique => true
    add_index :worldbuilder_religions, [:district_id, :slug], :unique => true
    add_index :worldbuilder_deities, [:district_id, :slug], :unique => true
    add_index :worldbuilder_planes, [:district_id, :slug], :unique => true
    add_index :worldbuilder_inhabitants, [:district_id, :slug], :unique => true
  end
end
