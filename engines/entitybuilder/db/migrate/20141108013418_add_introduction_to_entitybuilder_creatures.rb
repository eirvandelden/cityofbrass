class AddIntroductionToEntitybuilderCreatures < ActiveRecord::Migration[4.2]
  def change
    add_column :entitybuilder_creatures, :introduction, :text
  end
end
