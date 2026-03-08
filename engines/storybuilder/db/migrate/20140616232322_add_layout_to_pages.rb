class AddLayoutToPages < ActiveRecord::Migration[4.2]
  def change
    add_column :storybuilder_pages, :page_layout, :string
  end
end
