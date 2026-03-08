class AddIsHandoutToPages < ActiveRecord::Migration[4.2]
  def change
    add_column :storybuilder_pages, :player_handout, :boolean, default: false
  end
end
