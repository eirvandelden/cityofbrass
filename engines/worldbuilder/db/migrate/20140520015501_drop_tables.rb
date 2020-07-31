# frozen_string_literal: false

class DropTables < ActiveRecord::Migration
  def change
    drop_table :worldbuilder_atlas_entries
    drop_table :worldbuilder_deities
    drop_table :worldbuilder_inhabitants
    drop_table :worldbuilder_lore_records
    drop_table :worldbuilder_planes
    drop_table :worldbuilder_religions
  end
end
