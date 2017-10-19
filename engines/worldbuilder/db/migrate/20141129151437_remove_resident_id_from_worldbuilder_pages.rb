class RemoveResidentIdFromWorldbuilderPages < ActiveRecord::Migration
  def change
    remove_column :worldbuilder_pages, :resident_id, :uuid
  end
end
