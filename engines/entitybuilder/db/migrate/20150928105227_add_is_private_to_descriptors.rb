class AddIsPrivateToDescriptors < ActiveRecord::Migration
  def change
    add_column :entitybuilder_descriptors, :is_private, :boolean, :default => false
  end
end
