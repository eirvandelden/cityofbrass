class CreateEntitybuilderSpecialAbilities < ActiveRecord::Migration
  def change
    create_table :entitybuilder_special_abilities, id: :uuid do |t|
      t.uuid :special_abilityable_id
      t.string :special_abilityable_type
      t.integer :sort_order
      t.string :name, :null => false
      t.string :short_description
      t.text :full_description
      t.string :special_ability_type

      t.timestamps
    end

    add_index :entitybuilder_special_abilities, [:special_abilityable_id, :special_abilityable_type], :name => 'eb_special_ability_id_and_type'
    add_index :entitybuilder_special_abilities, [:special_abilityable_id, :name], :unique => true, :name => 'eb_special_ability_name'
  end
end
