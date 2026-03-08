class RemoveNameIndexClassLevels < ActiveRecord::Migration[4.2]
  def change
    remove_index :entitybuilder_class_levels, name: 'eb_class_level_name'
  end
end
