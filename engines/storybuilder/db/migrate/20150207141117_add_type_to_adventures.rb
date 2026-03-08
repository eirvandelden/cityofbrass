class AddTypeToAdventures < ActiveRecord::Migration[4.2]
  def change
    add_column :storybuilder_adventures, :type, :string
  end
end
