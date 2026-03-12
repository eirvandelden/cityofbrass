class AddProficiencyBonusToStuff < ActiveRecord::Migration[4.2]
  def change
    add_column :entitybuilder_skills, :proficient, :boolean
    add_column :entitybuilder_saving_throws, :proficient, :boolean
    add_column :entitybuilder_attacks, :proficient, :boolean
    add_column :entitybuilder_items, :proficient, :boolean
  end
end
