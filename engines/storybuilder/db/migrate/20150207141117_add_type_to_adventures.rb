class AddTypeToAdventures < ActiveRecord::Migration
  def change
    add_column :storybuilder_adventures, :type, :string
  end
end
