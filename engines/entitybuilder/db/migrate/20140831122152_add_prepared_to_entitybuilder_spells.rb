class AddPreparedToEntitybuilderSpells < ActiveRecord::Migration[4.2]
  def change
    add_column :entitybuilder_spells, :prepared, :boolean
  end
end
