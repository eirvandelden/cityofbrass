class AddPageLabelToWorldbuilderDistricts < ActiveRecord::Migration[4.2]
  def change
    add_column :worldbuilder_districts, :page_label, :string
  end
end
