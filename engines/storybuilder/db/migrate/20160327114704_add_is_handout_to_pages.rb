class AddIsHandoutToPages < ActiveRecord::Migration
  def change
    add_column :storybuilder_pages, :player_handout, :boolean, default: false
  end
end
