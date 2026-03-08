class AddProficientToCasterLevel < ActiveRecord::Migration[4.2]
  def change
    add_column :entitybuilder_caster_levels, :proficient, :boolean
  end
end
