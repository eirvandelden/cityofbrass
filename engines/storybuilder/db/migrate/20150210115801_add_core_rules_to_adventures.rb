class AddCoreRulesToAdventures < ActiveRecord::Migration[4.2]
  def change
    add_column :storybuilder_adventures, :core_rules, :string
  end
end
