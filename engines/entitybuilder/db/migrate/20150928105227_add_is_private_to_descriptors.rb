class AddIsPrivateToDescriptors < ActiveRecord::Migration[4.2]
  def change
    add_column :entitybuilder_descriptors, :is_private, :boolean, default: false
  end
end
