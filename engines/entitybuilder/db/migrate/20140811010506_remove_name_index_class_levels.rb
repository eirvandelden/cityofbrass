class RemoveNameIndexClassLevels < ActiveRecord::Migration
  def change
    remove_index :entitybuilder_class_levels, :name => 'eb_class_level_name'
  end
end
