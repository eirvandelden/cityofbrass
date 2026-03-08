class RemovePageTypeNullConstraint < ActiveRecord::Migration[4.2]
  def change
    change_column_null :storybuilder_pages, :type, true
    change_column_null :storybuilder_pages, :name, true
    change_column_null :storybuilder_pages, :slug, true
    change_column_null :storybuilder_pages, :privacy, true

    remove_index :storybuilder_pages, [ :adventure_id, :type, :slug ]
    add_index :storybuilder_pages, :adventure_id
  end
end
